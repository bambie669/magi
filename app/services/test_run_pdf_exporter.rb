require 'prawn'
require 'prawn/table'

class TestRunPdfExporter
  STATUS_COLORS = {
    'passed' => '00FF41',
    'failed' => 'B00020',
    'blocked' => 'FF9F0A',
    'untested' => '6B6B6B'
  }.freeze

  STATUS_LABELS = {
    'passed' => 'NOMINAL',
    'failed' => 'BREACH',
    'blocked' => 'BLOCKED',
    'untested' => 'STANDBY'
  }.freeze

  def initialize(test_run)
    @test_run = test_run
    @project = test_run.project
  end

  def to_pdf
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      render_header(pdf)
      render_summary(pdf)
      render_results_table(pdf)
      render_details(pdf)
      render_footer(pdf)
    end.render
  end

  private

  # Sanitize text to be compatible with PDF's built-in fonts (Windows-1252)
  def sanitize_text(text)
    return '' if text.blank?
    text.to_s.encode('Windows-1252', invalid: :replace, undef: :replace, replace: '?')
  end

  def render_header(pdf)
    pdf.font('Helvetica', style: :bold, size: 18) do
      pdf.text sanitize_text("OPERATION REPORT: #{@test_run.name.upcase}"), color: '6B5B95'
    end

    pdf.move_down 10
    pdf.font('Helvetica', size: 10) do
      pdf.text sanitize_text("Mission: #{@project.name}"), color: '666666'
      pdf.text sanitize_text("Initiated by: #{@test_run.user.display_name}"), color: '666666'
      pdf.text "Date: #{@test_run.created_at.strftime('%Y.%m.%d %H:%M')}", color: '666666'
      pdf.text "Export Date: #{Time.current.strftime('%Y.%m.%d %H:%M')}", color: '666666'
    end

    pdf.move_down 5
    pdf.stroke_color '6B5B95'
    pdf.stroke_horizontal_rule
    pdf.move_down 15
  end

  def render_summary(pdf)
    stats = calculate_stats

    pdf.font('Helvetica', style: :bold, size: 12) do
      pdf.text 'OPERATION SUMMARY', color: '1A0022'
    end
    pdf.move_down 10

    # Summary table
    summary_data = [
      ['Total Protocols', stats[:total].to_s],
      ['Completion', "#{stats[:completion_percentage]}%"],
      ['Nominal (Passed)', { content: stats[:passed].to_s, text_color: '00FF41' }],
      ['Breach (Failed)', { content: stats[:failed].to_s, text_color: 'B00020' }],
      ['Blocked', { content: stats[:blocked].to_s, text_color: 'FF9F0A' }],
      ['Standby (Untested)', stats[:untested].to_s]
    ]

    pdf.table(summary_data, width: 250) do |t|
      t.cells.borders = [:bottom]
      t.cells.border_color = 'DDDDDD'
      t.cells.padding = [5, 10]
      t.column(0).font_style = :bold
      t.column(1).align = :right
    end

    pdf.move_down 20
  end

  def render_results_table(pdf)
    pdf.font('Helvetica', style: :bold, size: 12) do
      pdf.text 'EXECUTION RESULTS', color: '1A0022'
    end
    pdf.move_down 10

    results = @test_run.test_run_cases
      .includes(:test_case, :user)
      .order('test_cases.title ASC')

    table_data = [['#', 'Protocol', 'Status', 'Operator']]

    results.each_with_index do |trc, index|
      status = trc.status || 'untested'
      status_label = STATUS_LABELS[status] || 'STANDBY'

      table_data << [
        (index + 1).to_s,
        sanitize_text(truncate_text(trc.test_case.title, 35)),
        status_label,
        sanitize_text(trc.user&.display_name || '-')
      ]
    end

    pdf.table(table_data, width: pdf.bounds.width, header: true) do |t|
      t.cells.borders = [:bottom]
      t.cells.border_color = 'DDDDDD'
      t.cells.padding = [5, 8]
      t.row(0).font_style = :bold
      t.row(0).background_color = '1A0022'
      t.row(0).text_color = 'FFFFFF'
      t.column(0).width = 30
      t.column(2).width = 70
      t.column(3).width = 90

      # Color code status column
      (1...table_data.length).each do |i|
        status = results[i - 1].status || 'untested'
        t.row(i).column(2).text_color = STATUS_COLORS[status]
      end
    end

    pdf.move_down 20
  end

  def render_details(pdf)
    failed_cases = @test_run.test_run_cases
      .includes(:test_case, :user)
      .where(status: 'failed')
      .order('test_cases.title ASC')

    return if failed_cases.empty?

    pdf.start_new_page if pdf.cursor < 200

    pdf.font('Helvetica', style: :bold, size: 12) do
      pdf.text 'BREACH DETAILS', color: 'B00020'
    end
    pdf.move_down 10

    failed_cases.each do |trc|
      render_failure_detail(pdf, trc)
      pdf.move_down 15

      pdf.start_new_page if pdf.cursor < 100
    end
  end

  def render_failure_detail(pdf, trc)
    pdf.fill_color 'B00020'
    pdf.fill_rectangle [0, pdf.cursor], 3, 50
    pdf.fill_color '000000'

    pdf.indent(10) do
      pdf.font('Helvetica', style: :bold, size: 10) do
        pdf.text sanitize_text(trc.test_case.title), color: '333333'
      end

      if trc.comments.present?
        pdf.move_down 5
        pdf.font('Helvetica', size: 9) do
          pdf.text sanitize_text("Comments: #{trc.comments}"), color: '666666'
        end
      end

      pdf.move_down 3
      pdf.font('Helvetica', size: 8) do
        pdf.text sanitize_text("Reported by: #{trc.user&.display_name || 'Unknown'} at #{trc.updated_at&.strftime('%Y.%m.%d %H:%M')}"),
          color: '999999'
      end
    end
  end

  def render_footer(pdf)
    pdf.repeat(:all, dynamic: true) do
      pdf.bounding_box([0, 25], width: pdf.bounds.width, height: 20) do
        pdf.font('Helvetica', size: 8) do
          pdf.text sanitize_text("NERV MAGI QA System - #{@project.name} - #{@test_run.name} - Page #{pdf.page_number}"),
            align: :center, color: '999999'
        end
      end
    end
  end

  def calculate_stats
    cases = @test_run.test_run_cases
    total = cases.count
    passed = cases.where(status: 'passed').count
    failed = cases.where(status: 'failed').count
    blocked = cases.where(status: 'blocked').count
    untested = total - passed - failed - blocked

    executed = passed + failed + blocked
    completion = total > 0 ? ((executed.to_f / total) * 100).round : 0

    {
      total: total,
      passed: passed,
      failed: failed,
      blocked: blocked,
      untested: untested,
      completion_percentage: completion
    }
  end

  def truncate_text(text, length)
    return '' if text.blank?
    text.length > length ? "#{text[0...length]}..." : text
  end
end
