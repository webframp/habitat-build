#
# Copyright:: Copyright (c) 2016 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module HabitatBuildCookbook
  module Helpers
    #
    # Get the plan directory from the config, or fallback to /src, set
    # this in .delivery/config.json.
    #
    # Examples:
    # {
    #   ...
    #   "habitat": {
    #     "plan_dir": "/src/plans"
    #     "plan_dir": "/elsewhere/plans/myplan"
    #   }
    # }
    def habitat_plan_dir
      if node['delivery']['config'].attribute?('habitat') &&
         node['delivery']['config']['habitat'].attribute?('plan_dir')
        node['delivery']['config']['habitat']['plan_dir']
      else
        '/src/habitat'
      end
    end

    def habitat_origin_key?
      project_secrets_exist?(%w(keyname private_key public_key))
    end

    def habitat_depot_token?
      project_secrets_exist?(%w(depot_token))
    end

    def hab_binary
      if platform_family?('mac_os_x')
        '/usr/local/bin/hab'
      else
        '/bin/hab'
      end
    end

    def changed_habitat_files?
      # `changed_files` comes from the delivery-sugar DSL: https://git.io/vXvAm
      changed_files.select { |changed_file| changed_file =~ %r{habitat/} }.any?
    end

    # if we're going to load secrets, we need to make sure we actually
    # have the data!
    def project_secrets_exist?(secret_keys = [])
      load_delivery_chef_config

      begin
        key_data = get_project_secrets.to_hash
      rescue Net::HTTPServerException
        return false
      end

      return false unless key_data.key?('habitat') && !key_data['habitat'].empty?

      secret_keys.each do |req_key|
        next if key_data['habitat'].key?(req_key) && !key_data['habitat'][req_key].empty?
        return false
      end

      true
    end
  end
end

Chef::Recipe.send(:include, HabitatBuildCookbook::Helpers)
Chef::Resource.send(:include, HabitatBuildCookbook::Helpers)
