# frozen_string_literal: true

# Create a Data View
class CreateDataView
  include ServiceStatus
  attr_reader :data_view

  def run(data_view_params, stream_ids, user, home_view=false)

    # normal data view
    @data_view = DataView.new(data_view_params.merge({owner: user}))

    # build nilm associations for permissions
    begin
      #retrieve nilms for every stream in this view
      db_ids = DbStream
        .find(stream_ids)
        .pluck(:db_id)
        .uniq
      nilm_ids = Db
        .find(db_ids)
        .pluck(:nilm_id)
    rescue ActiveRecord::RecordNotFound
      self.add_errors(['invalid stream_ids'])
      return self
    end
    unless @data_view.save
      self.add_errors(@data_view.errors.full_messages)
      return self
    end
    @data_view.nilm_ids = nilm_ids
    user.update(home_data_view: @data_view) if home_view
    self.set_notice('created data view')
    self
  end
end