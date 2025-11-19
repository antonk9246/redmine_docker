module IssuesRules
  module Patches
    module SettingsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :plugin_without_valid, :plugin
          alias_method :plugin, :plugin_with_valid
        end
      end

      module InstanceMethods
        @@choosen_tracker  ||= ''
        def plugin_with_valid
          @plugin = Redmine::Plugin.find(params[:id])
          if @plugin.id ==  :issues_rules
            params[:master_tracker] ? @@choosen_tracker  = params[:master_tracker].to_s : @@choosen_tracker ||= ''   
            hierarchical_logic(@@choosen_tracker)
            #plugin_with_validation
          else
            plugin_without_valid
          end
        end

        def hierarchical_logic(params_for_partial)
          @plugin = Redmine::Plugin.find(params[:id])
          unless @plugin.configurable?
            render_404
            return
          end
                    
          if request.post?
            
            change_tracker_relations(params[:parent_tracker] ,'parent') unless @@choosen_tracker.empty? #вынести 'parent' и 'child' в константу
            change_tracker_relations(params[:child_tracker] ,'child') unless @@choosen_tracker.empty?
            change_tracker_writeoff(params[:checkbox])

            #change_time_write_off(params[:checkbox])
            redirect_to plugin_settings_path(@plugin)
            
          elsif request.get?
            master_tracker = Tracker.where(name: params[:master_tracker])
          
            unless master_tracker.empty?
              @parent_trackers = []
              @child_trackers = []
              @with_empty_value_parent = []
              @with_empty_value_child = []
              @all_trackers_hash = []
              parent_trackers_ids = RelatedTracker.where(child_id: master_tracker.ids)
              child_trackers_ids = RelatedTracker.where(parent_id: master_tracker.ids)
              
              Tracker.all.each do |tracker|
                @all_trackers_hash << tracker
              end
              @all_trackers_hash << Tracker.new(id:0, name: "<-Project->")


              parent_trackers_ids.each do |tracker|
                if tracker.parent_id == 0
                  @parent_trackers << {id: 0 , name: '<-Project->'}
                else 
                  temp_tracker = Tracker.find_by(id: tracker.parent_id)
                  @parent_trackers << {id: temp_tracker.id, name: temp_tracker.name} if temp_tracker
                end
              end
        
              child_trackers_ids.each do |tracker|
                Tracker.where(id: tracker.child_id).select(:id,:name).each do |tracker|
                  @child_trackers << {id: tracker.id , name: tracker.name}
                end          
              end  
            end

            @partial = @plugin.settings[:partial]
          else
            @partial = @plugin.settings[:partial]
            @settings = Setting.send "plugin_#{@plugin.id}"
          end
        rescue Redmine::PluginNotFound
          render_404          
        end

        def change_tracker_writeoff(parameters)
          parameters ? new_writeoff_ids_hash = parameters.keys : new_writeoff_ids_hash = []
          exist_writeoff_ids = Tracker.where(writeoff_f: true).select(:id)
          exist_writeoff_ids_hash = []

          exist_writeoff_ids.each do |object|
            exist_writeoff_ids_hash << object.id.to_s
          end

          ms_to_add = new_writeoff_ids_hash - exist_writeoff_ids_hash
          ms_to_dell = exist_writeoff_ids_hash - new_writeoff_ids_hash
          
          
          
          add_new_writeoff(ms_to_add)
          delete_old_writeoff(ms_to_dell)

        end

        def change_tracker_relations(tracker_array,change_column)
          ms_for_del = []
          new_relation = []
          ms_trackers = []
          ms_for_add = []
          exist_relation = []
          new_relation = []
          tracker_array ||= []
          master_tracker = Tracker.where(name: @@choosen_tracker)   
          if change_column.downcase == 'parent'
            exist_relation = RelatedTracker.where(child_id: master_tracker.first.id).select(:parent_id, :child_id)
            tracker_array.each do |tracker|
              new_relation << RelatedTracker.new(parent_id: tracker, child_id: master_tracker.first.id)
              ms_for_add << {parent_id: tracker, child_id: master_tracker.first.id}
            end
          elsif change_column.downcase == 'child'
            exist_relation = RelatedTracker.where(parent_id: master_tracker.first.id).select(:parent_id, :child_id)
            tracker_array.each do |tracker|
              new_relation << RelatedTracker.new(parent_id: master_tracker.first.id, child_id: tracker)
              ms_for_add << {parent_id: master_tracker.first.id, child_id: tracker}
            end
          end
          exist_relation.each do |tracker|
            ms_for_del << {parent_id: tracker.parent_id, child_id: tracker.child_id}
          end
          
          
          ms_for_add = array_subtraction(exist_relation,ms_for_add).uniq
          ms_for_del = array_subtraction(new_relation,ms_for_del).uniq
                    
          add_new_relations(ms_for_add)
          delete_old_relations(ms_for_del)
        end

        def array_subtraction(left,right)
          left.each do |new_r|
            right.each do |for_del|
              if for_del[:parent_id].to_i == new_r.parent_id && for_del[:child_id].to_i == new_r.child_id
                right.delete(for_del)
              end
            end
          end
          right
        end

        def add_new_writeoff(ms_for_add)
          ms_for_add.each do |tracker_id|
            tracker = Tracker.find_by(id: tracker_id)
            tracker.writeoff_f = true
            tracker.save
          end
        end

        def delete_old_writeoff(ms_for_del)
          ms_for_del.each do |tracker_id|
            tracker = Tracker.find_by(id: tracker_id)
            tracker.writeoff_f = false
            tracker.save
          end
        end

        def add_new_relations(ms_for_add)
          ms_for_add.each do |tracker|
            new_relation = RelatedTracker.new(parent_id: tracker[:parent_id], child_id: tracker[:child_id])
            new_relation.save
          end
        end

        def delete_old_relations(ms_for_del)
          ms_for_del.each do |tracker|
            relation_for_del = RelatedTracker.where(parent_id: tracker[:parent_id], child_id: tracker[:child_id])
            RelatedTracker.destroy(relation_for_del.first.id)
          end
        end
      end
    end
  end
end

unless SettingsController.included_modules.include?(IssuesRules::Patches::SettingsControllerPatch)
  SettingsController.include IssuesRules::Patches::SettingsControllerPatch
end