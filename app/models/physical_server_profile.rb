class PhysicalServerProfile < ApplicationRecord
  acts_as_miq_taggable

  include NewWithTypeStiMixin
  include TenantIdentityMixin
  include SupportsFeatureMixin

  # TODO: this model doesn't have an event_where_clause, doesn't have a *_id in event_streams but includes
  # event mixin.  Track down if we need timeline events for this as they look to not be completely supported yet.
  include EventMixin
  include ProviderObjectMixin
  include EmsRefreshMixin

  include Operations

  belongs_to :ext_management_system, :foreign_key => :ems_id, :inverse_of => :physical_server_profiles,
    :class_name => "ManageIQ::Providers::PhysicalInfraManager"

  belongs_to :assigned_server, :optional => true, :inverse_of => :assigned_server_profile, :class_name => "::PhysicalServer"
  belongs_to :associated_server, :optional => true, :inverse_of => :associated_server_profile, :class_name => "::PhysicalServer"

  delegate :queue_name_for_ems_operations, :to => :ext_management_system, :allow_nil => true

  def my_zone
    ems = ext_management_system
    ems ? ems.my_zone : MiqServer.my_zone
  end
end
