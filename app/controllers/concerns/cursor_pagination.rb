module CursorPagination
  extend ActiveSupport::Concern

  private

  def cursor_params
    {
      order_by: params[:order_by].presence || "id",
      order_direction: (params[:order_direction]&.upcase == "ASC" ? "ASC" : "DESC"),
      limit: (params[:limit].presence || 20).to_i,
      cursor: params[:cursor]
    }
  end

  def apply_cursor_pagination(scope)
    cursor = cursor_params
    validate_order_column!(cursor[:order_by])

    scope = scope.order(cursor[:order_by] => cursor[:order_direction], id: cursor[:order_direction])

    if cursor[:cursor].present?
      decoded = decode_cursor(cursor[:cursor])
      operator = cursor[:order_direction] == "DESC" ? "<" : ">"

      scope = scope.where(
        "#{cursor[:order_by]} #{operator} :value OR (#{cursor[:order_by]} = :value AND id #{operator} :id)",
        value: decoded[:value],
        id: decoded[:id]
      )
    end

    scope.limit(cursor[:limit])
  end

  def encode_cursor(record, order_by)
    return nil unless record

    value = record.send(order_by)
    Base64.strict_encode64({
      value: value.is_a?(Time) ? value.iso8601(6) : value,
      id: record.id
    }.to_json)
  end

  def decode_cursor(cursor)
    decoded = JSON.parse(Base64.strict_decode64(cursor))
    {
      value: decoded["value"],
      id: decoded["id"]
    }
  rescue
    raise ActionController::BadRequest, "Invalid cursor format"
  end

  def validate_order_column!(column)
    unless model_class.column_names.include?(column.to_s)
      raise ActionController::BadRequest, "Invalid order_by column: #{column}"
    end
  end

  def model_class
    controller_name.classify.constantize
  end
end
