module SimpleParams
  TYPE_MAPPINGS = {
    integer: Integer,
    string: String,
    decimal: BigDecimal,
    datetime: DateTime,
    date: Date,
    time: Time,
    float: Float,
    boolean: Axiom::Types::Boolean, # See note on Virtus
    array: Array,
    hash: Hash,
    object: Object
  }
end