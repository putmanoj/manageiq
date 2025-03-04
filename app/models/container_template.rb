class ContainerTemplate < ApplicationRecord
  include CustomAttributeMixin
  include CustomActionsMixin
  include SupportsFeatureMixin

  belongs_to :ext_management_system, :foreign_key => "ems_id"
  belongs_to :container_project
  has_many :container_template_parameters, :dependent => :destroy
  has_many :annotations, -> { where(:section => "annotations") }, # rubocop:disable Rails/HasManyOrHasOneDependent
           :class_name => "CustomAttribute",
           :as         => :resource,
           :inverse_of => :resource
  has_many :labels, -> { where(:section => "labels") }, # rubocop:disable Rails/HasManyOrHasOneDependent
           :class_name => "CustomAttribute",
           :as         => :resource,
           :inverse_of => :resource

  serialize :objects, :type => Array
  serialize :object_labels, :type => Hash

  acts_as_miq_taggable

  def instantiate(_params, _project_name)
    raise NotImplementedError, _("instantiate must be implemented in a subclass")
  end
end
