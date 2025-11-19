require 'write_xlsx'

module RedmineXlsxFormatIssueExporter
  module XlsxExportHelper
    include ApplicationHelper

    def query_to_xlsx(items, query, options={})
      columns = create_columns_list(query, options)
      export_to_xlsx(items, columns, query)
    end

    def create_columns_list(query, options)
      if (options[:columns].present? and options[:columns].include?('all_inline')) or
         (options[:c].present? and options[:c].include?('all_inline'))
        columns = query.available_inline_columns
      else
        columns = query.inline_columns
      end

      query.available_block_columns.each do |column|  # Some versions have description in query.
        if options[column.name].present?
          columns << column
        end
      end

      if options['files'].present?
        columns << FilesQueryColumn.new(:files)
      end

      columns
    end

    def export_to_xlsx(items, columns, query)
      stream = StringIO.new('')
      workbook = WriteXLSX.new(stream)
      worksheet = workbook.add_worksheet

      worksheet.freeze_panes(1, 1)  # Freeze header row and # column.

      columns_width = []

      write_header_row(workbook, worksheet, columns, columns_width)
      write_item_rows(workbook, worksheet, columns, items, columns_width, query)
      columns.size.times do |index|
        worksheet.set_column(index, index, columns_width[index])
      end

      workbook.close

      stream.string
    end

    def write_header_row(workbook, worksheet, columns, columns_width)
      header_format = create_header_format(workbook)
      columns.each_with_index do |c, index|
        if c.class.name == 'String'
            value = c
        else
            value = c.caption.to_s
        end

        worksheet.write(0, index, value, header_format)
        columns_width << get_column_width(value)
      end
    end

    def write_item_rows(workbook, worksheet, columns, items, columns_width, query)
      hyperlink_format = create_hyperlink_format(workbook)
      cell_format = create_cell_format(workbook)
      group_order = 0
      last_row = 0
      columns_count = columns.count - 1
      grouped_query_results_with_index(items, query) do |item, group_name, group_count, group_totals, item_index|
        if group_name
          s = group_name
          hours = group_totals[/(\d+.?\d*)/]
          value = l(:text_items_count) + group_count.to_s + '   ' + group_totals.to_s
          row_index = item_index + group_order + 1
          worksheet.write(row_index, 0, s, create_group_format(workbook))
          width = get_column_width(s)
          columns_width[0] = width if columns_width[0] < width
          worksheet.merge_range(row_index, 1, row_index, columns_count - 1, value, create_group_format(workbook))
          worksheet.write(row_index, columns_count, hours, create_group_format(workbook))
          group_order += 1
        end
        columns.each_with_index do |c, column_index|
          value = xlsx_content(c, item)
          row_index = item_index + group_order
          write_item(worksheet, value, row_index, column_index, cell_format, (c.name == :id), item.id, hyperlink_format)

          width = get_column_width(value)
          columns_width[column_index] = width if columns_width[column_index] < width
          last_row = row_index
        end
      end
      if query.totalable_columns.any?
        value = ''
        query.totalable_columns.each_with_index do |c, column_index|
          value += total_value(c, query.total_for(c))
          value += '  '
        end
        s = l(:label_total_plural) + ':'
        worksheet.write(last_row + 2, 0, s, create_group_format(workbook))
        width = get_column_width(s)
        columns_width[0] = width if columns_width[0] < width
        worksheet.merge_range(last_row + 2, 1, last_row + 2, columns_count, value, create_group_format(workbook))
      end
    end

    def xlsx_content(column, item)
      csv_content(column, item)
    end

    # Conditions from worksheet.rb in write_xlsx.
    def is_transformed_to_hyperlink?(token)
      # Match http, https or ftp URL
      if token =~ %r|\A[fh]tt?ps?://|
        true
        # Match mailto:
      elsif token =~ %r|\Amailto:|
        true
        # Match internal or external sheet link
      elsif token =~ %r!\A(?:in|ex)ternal:!
        true
      end
    end

    def write_item(worksheet, value, row_index, column_index, cell_format, is_id_column, id, hyperlink_format)
      if is_id_column
        issue_url = url_for(:controller => 'issues', :action => 'show', :id => id)
        worksheet.write(row_index + 1, column_index, issue_url, hyperlink_format, value)
        return
      end

      if is_transformed_to_hyperlink?(value)
        worksheet.write_string(row_index + 1, column_index, value, cell_format)
        return
      end

      worksheet.write(row_index + 1, column_index, value, cell_format)
    end

    def get_column_width(value)
      value_str = value.to_s
      width = (value_str.length + value_str.chars.reject(&:ascii_only?).length) * 1.1  # 1.1: margin
      width > 30 ? 30 : width  # 30: max width
    end

    def create_header_format(workbook)
      workbook.add_format(:bold => 1,
                          :border => 1,
                          :color => 'white',
                          :bg_color => 'gray',
                          :text_wrap => 1,
                          :valign => 'top')
    end

    def create_cell_format(workbook)
      workbook.add_format(:border => 1,
                          :text_wrap => 1,
                          :valign => 'top')
    end

    def create_hyperlink_format(workbook)
      workbook.add_format(:border => 1,
                          :text_wrap => 1,
                          :valign => 'top',
                          :color => 'blue',
                          :underline => 1)
    end

    def create_group_format(workbook)
      workbook.add_format(:border => 0,
                          :color => 'white',
                          :bg_color => 'gray',
                          :text_wrap => 1,
                          :valign => 'top')
    end

    def grouped_issue_list_with_index(issues, query, &block)
      ancestors = []
      grouped_query_results_with_index(issues, query) do |issue, group_name, group_count, group_totals, index|
        while (ancestors.any? && !issue.is_descendant_of?(ancestors.last))
          ancestors.pop
        end
        yield issue, ancestors.size, group_name, group_count, group_totals, index
        ancestors << issue unless issue.leaf?
      end
    end

    def grouped_query_results_with_index(items, query, &block)
      result_count_by_group = query.result_count_by_group
      previous_group, first = false, true
      totals_by_group = query.totalable_columns.inject({}) do |h, column|
        h[column] = query.total_by_group_for(column)
        h
      end
      items.each_with_index do |item, index|
        group_name = group_count = nil
        if query.grouped?
          group = query.group_by_column.value(item)
          if first || group != previous_group
            if group.blank? && group != false
              group_name = "(#{l(:label_blank_value)})"
            else
              if group.class.eql?(Date)
                group_name = group.to_s
              elsif group.class.eql?(Fixnum)
                group_name =  group.to_s 
              else 
                group_name = group.name
              end
            end
            group_name ||= ""
            group_count = result_count_by_group ? result_count_by_group[group] : nil
            if group.is_a?(Version)
              group_totals = totals_by_group.map {|column, t| total_value(column, t[group.id] || 0)}.join(" ").html_safe
            else
              group_totals = totals_by_group.map {|column, t| total_value(column, t[group] || 0)}.join(" ").html_safe
            end
          end
        end
        yield item, group_name, group_count, group_totals, index
        previous_group, first = group, false
      end
    end

    def total_value(column, value)
      s = column.caption + ': '
      if [:hours, :spent_hours, :total_spent_hours, :estimated_hours].include? column.name
        s += l_hours(value)
      else
        s += format_object(value)
      end
      s
    end
  end
end
