class ProcessTemplate < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  validates :code, presence: {message: 'code cannot be blank'}, uniqueness: {message: 'code should be uniq'}

  # has_many :process_custom_fields

  acts_as_customizable

  before_create :init_attr


  def init_attr
    self.type=ProcessType.get_type(self.class.name.sub(/ProcessTemplate/, ''))
  end
end
