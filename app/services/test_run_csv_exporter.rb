require 'csv'

class TestRunCsvExporter
  HEADERS = %w[test_case_title status executed_by executed_at comments].freeze

  def initialize(test_run)
    @test_run = test_run
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      @test_run.test_run_cases.includes(:test_case, :user).order('test_cases.title ASC').each do |trc|
        csv << build_row(trc)
      end
    end
  end

  def self.headers_only
    CSV.generate do |csv|
      csv << HEADERS
    end
  end

  private

  def build_row(test_run_case)
    [
      test_run_case.test_case.title,
      format_status(test_run_case.status),
      test_run_case.user&.display_name || 'Unassigned',
      test_run_case.updated_at&.strftime('%Y-%m-%d %H:%M'),
      escape_newlines(test_run_case.comments)
    ]
  end

  def format_status(status)
    case status
    when 'passed' then 'NOMINAL'
    when 'failed' then 'BREACH'
    when 'blocked' then 'BLOCKED'
    else 'STANDBY'
    end
  end

  def escape_newlines(text)
    return nil if text.blank?
    text.gsub("\r\n", "\\n").gsub("\n", "\\n")
  end
end
