class ImportsController < AdminController
  def create
    result = JsonImportService.new.call

    if result[:success]
      stats = result[:data]
      flash[:notice] = build_success_message(stats)
      redirect_to gerenciamento_path
    else
      flash[:alert] = "Import failed: #{result[:error]}"
      redirect_to gerenciamento_path
    end
  end

  private

  def build_success_message(stats)
    parts = ["Import completed successfully!"]
    parts.concat(build_stat_messages(stats))
    parts << build_error_message(stats[:errors]) if stats[:errors].any?
    parts.join(". ")
  end

  def build_stat_messages(stats)
    stat_configs.filter_map do |config|
      count = stats[config[:key]]
      format_stat_message(count, config[:label]) if count && count > 0
    end
  end

  def stat_configs
    [
      { key: :users_created, label: "users created" },
      { key: :users_skipped, label: "users skipped (already exist)" },
      { key: :courses_created, label: "courses created" },
      { key: :courses_skipped, label: "courses skipped" },
      { key: :enrollments_created, label: "enrollments created" }
    ]
  end

  def format_stat_message(count, label)
    "#{count} #{label}"
  end

  def build_error_message(errors)
    "#{errors.length} errors occurred (see logs)"
  end
end
