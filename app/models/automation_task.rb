class AutomationTask < MiqRequestTask
  AUTOMATE_DRIVES = false

  def automation_request
    miq_request
  end

  def automation_request=(object)
    self.miq_request = object
  end

  def self.get_description(_request_obj)
    "Automation Task"
  end

  def self.base_model
    AutomationTask
  end

  def statemachine_task_status
    state == "finished" ? status.to_s.downcase : "retry"
  end

  def do_request
    args = {}
    args[:object_type]      = self.class.name
    args[:object_id]        = id
    args[:attrs]            = options[:attrs]
    args[:namespace]        = options[:namespace]
    args[:class_name]       = options[:class_name]
    args[:instance_name]    = options[:instance_name]
    args[:user_id]          = options[:user_id]
    args[:miq_group_id]     = options[:miq_group_id] || User.find(options[:user_id]).current_group.id
    args[:tenant_id]        = options[:tenant_id] || User.find(options[:user_id]).current_tenant.id
    args[:automate_message] = options[:message]
    args[:attrs][:dialog_param_parent_request_id] = miq_request_id unless miq_request_id.nil?

    MiqAeEngine.deliver(args)
  end

  def after_ae_delivery(ae_result)
    _log.info("ae_result=#{ae_result.inspect}")

    return if ae_result == 'retry' || miq_request.state == 'finished'

    if ae_result == 'ok'
      update_and_notify_parent(:state => "finished", :status => "Ok",    :message => "#{request_class::TASK_DESCRIPTION} completed")
    else
      update_and_notify_parent(:state => "finished", :status => "Error", :message => "#{request_class::TASK_DESCRIPTION} failed")
    end
  end
end
