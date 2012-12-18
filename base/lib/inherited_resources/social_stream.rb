# Monkey path inherited_resources
#
#
# Pull request https://github.com/josevalim/inherited_resources/pull/237
module InheritedResources::BaseHelpers
  private

  def resource_params
    @resource_params ||=
      build_resource_params
  end

  def build_resource_params
    rparams = [whitelisted_params || params[resource_request_name] || params[resource_instance_name] || {}]
    rparams << as_role if role_given?
    rparams
  end

  def whitelisted_params
    whitelist_method = :"#{ resource_request_name }_params"
    respond_to?(whitelist_method, true) && self.send(whitelist_method)
  end
end
