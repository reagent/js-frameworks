module Timestamps
  def enable_timestamps
    property :created_at, DateTime
    property :updated_at, DateTime
  end
end