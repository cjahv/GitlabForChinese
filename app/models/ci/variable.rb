module Ci
  class Variable < ActiveRecord::Base
    extend Ci::Model

    belongs_to :project

    validates :key,
      presence: true,
      uniqueness: { scope: :project_id },
      length: { maximum: 255 },
      format: { with: /\A[a-zA-Z0-9_]+\z/,
                message: "只能包含字母、数字和下划线。" }

    scope :order_key_asc, -> { reorder(key: :asc) }

    attr_encrypted :value,
       mode: :per_attribute_iv_and_salt,
       insecure_mode: true,
       key: Gitlab::Application.secrets.db_key_base,
       algorithm: 'aes-256-cbc'
  end
end
