# Monkey path inherited_resources
#
# Patch is already accepted in master
# Remove with inherited_resources > 1.4.0
module InheritedResources::BaseHelpers
  private

  # extract attributes from params
  def build_resource_params
    parameters = respond_to?(:permitted_params, true) ? permitted_params : params
    rparams = [parameters[resource_request_name] || parameters[resource_instance_name] || {}]
    if without_protection_given?
      rparams << without_protection
    else
      rparams << as_role if role_given?
    end

    rparams
  end
end
