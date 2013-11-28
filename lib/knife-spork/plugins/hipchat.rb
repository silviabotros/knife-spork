require 'knife-spork/plugins/plugin'

module KnifeSpork
  module Plugins
    class HipChat < Plugin
      name :hipchat

      def perform; end

      def after_upload
        hipchat "#{organization}#{current_user} uploaded the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")} to #{chef_server}"
      end

      def after_promote_remote
        hipchat "#{organization}#{current_user} promoted the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")} to #{environments.collect{ |e| "#{e.name}" }.join(", ")}on #{chef_server}"
      end

      def after_rolefromfile
        hipchat "#{organization}#{current_user} uploaded role #{object_name} to #{chef_server}"
      end

      def after_roleedit
        hipchat "#{organization}#{current_user} edited role #{object_name} on #{chef_server}"
      end

      def after_rolecreate
        hipchat "#{organization}#{current_user} created role #{object_name} on #{chef_server}"
      end

      def after_roledelete
        hipchat "#{organization}#{current_user} deleted role #{object_name} from #{chef_server}"
      end

      def after_databagedit
        hipchat "#{organization}#{current_user} edited data bag item #{object_name}:#{object_secondary_name} on #{chef_server}"
      end

      def after_databagcreate
        hipchat "#{organization}#{current_user} created data bag #{object_name} on #{chef_server}"
      end

      def after_databagdelete
        hipchat "#{organization}#{current_user} deleted data bag item #{object_name} from #{chef_server}"
      end

      def after_databagitemdelete
        hipchat "#{organization}#{current_user} deleted data bag item #{object_name}:#{object_secondary_name} on #{chef_server}"
      end

      def after_databagfromfile
        hipchat "#{organization}#{current_user} uploaded data bag item #{object_name}:#{object_secondary_name} to #{chef_server} "
      end

      def after_nodeedit
        hipchat "#{organization}#{current_user} edited node #{object_name} on #{chef_server}"
      end

      def after_nodedelete
        hipchat "#{organization}#{current_user} deleted node #{object_name} from #{chef_server}"
      end

      def after_nodecreate
        hipchat "#{organization}#{current_user} created node #{object_name} on #{chef_server}"
      end

      def after_nodefromfile
        hipchat "#{organization}#{current_user} uploaded node #{object_name} on #{chef_server}"
      end

      def after_noderunlistadd
        hipchat "#{organization}#{current_user} added run_list items to #{object_name}: #{object_secondary_name} on #{chef_server}"
      end

      def after_noderunlistremove
        hipchat "#{organization}#{current_user} removed run_list items from #{object_name}: #{object_secondary_name} on #{chef_server}"
      end

      def after_noderunlistset
        hipchat "#{organization}#{current_user} set the run_list for #{object_name} to #{object_secondary_name} on #{chef_server}"
      end


      private
      def hipchat(message)
        safe_require 'hipchat'

        rooms.each do |room_name|
          begin
            client = ::HipChat::Client.new(config.api_token)
            client[room_name].send(nickname, message, :notify => notify, :color =>color)
          rescue Exception => e
            ui.error 'Something went wrong sending to HipChat.'
            ui.error e.to_s
          end
        end
      end

      def rooms
        [ config.room || config.rooms ].flatten
      end

      def nickname
        config.nickname || 'KnifeSpork'
      end

      def notify
        config.notify.nil? ? true : config.notify
      end

      def color
        config.color || 'yellow'
      end
    end
  end
end
