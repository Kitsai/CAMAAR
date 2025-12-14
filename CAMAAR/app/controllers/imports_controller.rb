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
    parts << "#{stats[:users_created]} users created" if stats[:users_created] > 0
    parts << "#{stats[:users_skipped]} users skipped (already exist)" if stats[:users_skipped] > 0
    parts << "#{stats[:courses_created]} courses created" if stats[:courses_created] > 0
    parts << "#{stats[:courses_skipped]} courses skipped" if stats[:courses_skipped] > 0
    parts << "#{stats[:enrollments_created]} enrollments created" if stats[:enrollments_created] > 0

    if stats[:errors].any?
      parts << "#{stats[:errors].length} errors occurred (see logs)"
    end

    parts.join(". ")
  end
end
