require 'prawn'
require 'prawn/table'

class TestCasesPdfExporter
  def initialize(test_suite)
    @test_suite = test_suite
    @project = test_suite.project
  end

  def to_pdf
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      render_header(pdf)
      render_test_cases(pdf)
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
      pdf.text sanitize_text("PROTOCOL BANK: #{@test_suite.name.upcase}"), color: '6B5B95'
    end

    pdf.move_down 10
    pdf.font('Helvetica', size: 10, style: :normal) do
      pdf.text sanitize_text("Mission: #{@project.name}"), color: '666666'
      pdf.text "Export Date: #{Time.current.strftime('%Y.%m.%d %H:%M')}", color: '666666'
      pdf.text "Total Protocols: #{@test_suite.test_cases.count}", color: '666666'
    end

    pdf.move_down 5
    pdf.stroke_color '6B5B95'
    pdf.stroke_horizontal_rule
    pdf.move_down 15
  end

  def render_test_cases(pdf)
    test_cases = collect_test_cases_with_paths

    test_cases.each_with_index do |(test_case, scope_path), index|
      render_test_case(pdf, test_case, scope_path, index + 1)
      pdf.move_down 15

      # Start new page if near bottom
      if pdf.cursor < 150
        pdf.start_new_page
      end
    end
  end

  def render_test_case(pdf, test_case, scope_path, number)
    # Protocol header
    pdf.fill_color '1A0022'
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 25
    pdf.fill_color '000000'

    pdf.move_down 5
    pdf.font('Helvetica', style: :bold, size: 11) do
      pdf.fill_color 'FFFFFF'
      pdf.text_box sanitize_text("PROTOCOL #{number}: #{test_case.title}"),
        at: [5, pdf.cursor + 5],
        width: pdf.bounds.width - 10,
        height: 20,
        overflow: :truncate
      pdf.fill_color '000000'
    end
    pdf.move_down 20

    # Scope path
    pdf.font('Helvetica', size: 9) do
      pdf.text sanitize_text("Location: #{scope_path}"), color: '6B5B95', style: :italic
    end
    pdf.move_down 5

    # Cypress ID if present
    if test_case.cypress_id.present?
      pdf.font('Helvetica', size: 9) do
        pdf.text sanitize_text("Cypress ID: #{test_case.cypress_id}"), color: 'FF9F0A'
      end
      pdf.move_down 5
    end

    # Preconditions
    if test_case.preconditions.present?
      render_section(pdf, 'PRECONDITIONS', test_case.preconditions, 'B00020')
    end

    # Steps
    if test_case.steps.present?
      render_section(pdf, 'EXECUTION STEPS', test_case.steps, '00D4FF')
    end

    # Expected Result
    if test_case.expected_result.present?
      render_section(pdf, 'EXPECTED OUTCOME', test_case.expected_result, '00FF41')
    end
  end

  def render_section(pdf, title, content, color)
    pdf.font('Helvetica', style: :bold, size: 9) do
      pdf.fill_color color
      pdf.text title
      pdf.fill_color '000000'
    end
    pdf.move_down 3

    pdf.font('Helvetica', size: 10) do
      pdf.text sanitize_text(content), color: '333333', leading: 2
    end
    pdf.move_down 8
  end

  def render_footer(pdf)
    pdf.repeat(:all, dynamic: true) do
      pdf.bounding_box([0, 25], width: pdf.bounds.width, height: 20) do
        pdf.font('Helvetica', size: 8) do
          pdf.text sanitize_text("NERV MAGI QA System - #{@project.name} - Page #{pdf.page_number}"),
            align: :center, color: '999999'
        end
      end
    end
  end

  def collect_test_cases_with_paths
    results = []
    @test_suite.root_test_scopes.order(:name).each do |root_scope|
      collect_from_scope(root_scope, root_scope.name, results)
    end
    results
  end

  def collect_from_scope(scope, path, results)
    scope.test_cases.order(:title).each do |test_case|
      results << [test_case, path]
    end

    scope.children.order(:name).each do |child_scope|
      child_path = "#{path}/#{child_scope.name}"
      collect_from_scope(child_scope, child_path, results)
    end
  end
end
