class Labeling::SKOSXL::Base < Labeling::Base

  scope :target_in_edit_mode, lambda { 
    includes(:target) & Iqvoc::XLLabel.base_class.in_edit_mode
  }

  scope :by_label_origin, lambda { |origin|
    includes(:target) & self.label_class.by_origin(origin)
  }

  scope :label_editor_selectable, lambda { # Lambda because self.label_class is currently not known + we don't want to call it at load time!
    includes(:target) & self.label_class.editor_selectable
  }
  
  def self.create_for(o, t)
    find_or_create_by_owner_id_and_target_id(o.id, t.id)
  end

  # FIXME: Hmm... Why should I sort labelings (not necessarily pref_labelings) by pref_label???
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end

  def self.label_class
    Iqvoc::XLLabel.base_class
  end

    def self.partial_name(obj)
    "partials/labeling/skosxl/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/skosxl/edit_base"
  end

  def self.nested_edit_partial_name(obj)
    nil
  end

end
