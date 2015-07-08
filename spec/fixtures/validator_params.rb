class ValidatorParams < SimpleParams::Params
  string_param :name
  integer_param :age, optional: true, default: 37
  string_param :first_initial, default: lambda { |params, param| params.name[0] if params.name.present? }
  decimal_param :amount, optional: true, default: 0.10, formatter: lambda { |params, param| param.round(2) }
  param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}, formatter: :lower_case_colors
  param :height, optional: true, validations: { inclusion: { in: ["tall","supertall"]} }
  param :birth_date, type: :date
  param :born_on, type: :datetime
  param :bank_balance, type: :float, formatter: lambda { |params, amt| sprintf('$%.2f', amt) }
  param :weight, type: :decimal
  param :favorite_colors, type: :array
  param :pets, type: :hash
  param :car, type: :object
  param :submitted_at, type: :time
  param :has_cellphone, type: :boolean
  param :title, optional: true, default: "programmer"
  param :account_type, default: "checking", validations: { inclusion: { in: ["checking", "savings"] }}
  param :account_status, default: "active", validations: { inclusion: { in: ["active", "inactive"] }}
  param :username, type: :string, validations: { exclusion: { in: ['admin', 'demo'] } }

  nested_hash :address do
    string_param :street
    string_param :city, validations: { length: { in: 4..40 } }
    string_param :zip_code, optional: true, validations: { length: { in: 5..9 } }
    param :state, default: "North Carolina", formatter: :transform_state_code

    def transform_state_code(val)
      val == "SC" ? "South Carolina" : val
    end
  end

  nested_hash :phone do
    boolean_param :cell_phone, default: true
    string_param :phone_number, validations: { length: { in: 7..10 } }, formatter: lambda { |params, attribute| attribute.gsub(/\D/, "") }
    string_param :area_code, default: lambda { |params, param|
      if params.phone_number.present?
        params.phone_number[0..2]
      end
    }
  end

  nested_array :dogs do
    param :name
    param :age, type: :integer, validations: { inclusion: { in: 1..20 } }
  end

  def lower_case_colors(val)
    val.downcase
  end
end
