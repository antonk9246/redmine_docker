# frozen_string_literal: true

module LightboxHelper
  def link_to_attachment(attachment, **options)
    with_lightbox = false

    if options[:class].present? && options[:class].include?('icon-download')
      # we don't want lightbox for this link, because this case duplicated entries in image slide
    elsif attachment && attachment.is_pdf? || attachment.is_image? || attachment.is_video?
      with_lightbox = true
      options[:class] = lightbox_image_classes attachment, options[:class]
    end
    if with_lightbox
      options[:download] = true
      caption = lightbox_image_caption attachment

      options[:title] ||= "#{l :label_preview}: #{caption}"
      options[:rel] ||= 'attachments'

      options[:data] = { type: preview_type(attachment),
                         fancybox: options[:rel],
                         caption: caption }


    end

    if attachment.is_pdf? && options[:data]
      options[:data].merge!(url: "/pdfjs/web/viewer.html?file=#{download_named_attachment_url(attachment, filename: attachment.filename)}")
    end

    super attachment, **options
  end

  def link_to_preview(attachment, controller, **options)
    with_lightbox = false

    if options[:class].present? && options[:class].include?('icon-download')
      # we don't want lightbox for this link, because this case duplicated entries in image slide
    elsif attachment && attachment.is_pdf? || attachment.is_image? || attachment.is_video?
      with_lightbox = true
      options[:class] = lightbox_image_classes attachment, options[:class]
    end
    if with_lightbox
      options[:download] = true
      caption = lightbox_image_caption attachment

      options[:title] ||= "#{l :label_preview}: #{caption}"
      options[:rel] ||= 'attachments'

      options[:data] = { type: preview_type(attachment),
                         fancybox: options[:rel],
                         caption: caption }
    end

    if attachment.is_pdf? && options[:data]
      options[:data].merge!(url: "/pdfjs/web/viewer.html?file=#{download_named_attachment_url(attachment, filename: attachment.filename)}")
    end

    text = l('label_preview')
    html_options = options.slice!(:only_path, :filename)
    options[:only_path] = true unless options.key?(:only_path)
    url = "/#{controller}/download?id=#{attachment.id}&preview=1"
    link_to text, url, html_options
  end

  def thumbnail_tag(attachment)
    caption = lightbox_image_caption attachment

    options = { title: "#{l :label_preview}: #{caption}",
                rel: 'thumbnails',
                class: lightbox_image_classes(attachment, 'thumbnail') }

    options[:data] = { type: preview_type(attachment),
                       fancybox: options[:rel],
                       caption: caption }

    if attachment.is_pdf? && options[:data]
      options[:data].merge!(url: "/pdfjs/web/viewer.html?file=#{download_named_attachment_url(attachment, filename: attachment.filename)}")
    end

    link_to preview_image_tag(attachment),
            download_named_attachment_url(attachment, filename: attachment.filename),
            options
  end

  def lightbox_image_caption(attachment)
    caption = attachment.filename.dup
    caption << " - #{attachment.description}" if attachment.description.present?

    caption
  end

  def lightbox_image_classes(attachment, base_classes = '')
    classes = []
    classes << base_classes.split if base_classes.present?

    if attachment.is_video?
      classes << 'lightbox'
      classes << 'video'
    elsif attachment.is_image?
      classes << 'lightbox'
      classes << attachment.filename.split('.').last.downcase
    else
      classes << type_name(attachment)
    end

    classes.join ' '
  end

  def preview_type(attachment)
    if attachment.is_video?
      'video'
    elsif attachment.is_image?
      'image'
    else
      'iframe'
    end
  end

  def preview_image_tag(attachment)
    thumbnail_size = Setting.thumbnails_size.to_i
    case preview_type(attachment)
    when 'video'
      image_tag('/themes/vnc_responsive/icon/product/videocam.svg')
    when 'image'
      image_tag(thumbnail_path(attachment),
                srcset: "#{thumbnail_path attachment, size: thumbnail_size * 2} 2x",
                onerror: "this.style.display='none'",
                style: "max-width: #{thumbnail_size}px; max-height: #{thumbnail_size}px;")
    when 'iframe'
      image_tag('/themes/vnc_responsive/icon/product/file-new.svg')
    end
  end

  def type_name(attachment)
    attachment.filename.split('.')[-1]
  end
end
