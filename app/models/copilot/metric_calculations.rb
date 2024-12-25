# frozen_string_literal: true

# Calculate metrics from the Copilot API
module MetricCalculations
  def calculate_percentage_for(num)
    (num * 100).round(2)
  end

  def total_acceptances_for(usage_summary)
    acceptances = usage_summary.map do |day|
      count = day.total_acceptances_count
      count.nil? ? 0 : count
    end

    acceptances.sum
  end

  def total_suggestions_for(usage_summary)
    suggestions = usage_summary.map do |day|
      count = day.total_suggestions_count
      count.nil? ? 0 : count
    end

    suggestions.sum
  end

  def total_lines_accepted_for(usage_summary)
    lines_accepted = usage_summary.map do |day|
      count = day.total_lines_accepted
      count.nil? ? 0 : count
    end

    lines_accepted.sum
  end

  def total_lines_suggested_for(usage_summary)
    lines_suggested = usage_summary.map do |day|
      count = day.total_lines_suggested
      count.nil? ? 0 : count
    end

    lines_suggested.sum
  end

  def acceptance_by_language_for(usage_summary)
    lang_summary = {}

    usage_summary.each do |summary|
      breakdown = summary.breakdown

      breakdown.each do |b|
        language = b.language

        if !lang_summary.key?(language)
          lang_summary[language] = {
            suggestions_count: b.suggestions_count,
            acceptances_count: b.acceptances_count,
            active_users: b.active_users
          }
        else
          stats = lang_summary[language]

          stats.tap do |stat|
            stat[:suggestions_count] += b.suggestions_count
            stat[:acceptances_count] += b.acceptances_count
            stat[:active_users] += b.active_users
          end
        end
      end
    end

    lang_summary
  end

  def daily_summary_for(metrics)
    metrics.map do |metric|
      {
        date: metric[:date],
        ide_total_engaged_users: metric.copilot_ide_chat.total_engaged_users,
        dotcom_total_engaged_users: metric.copilot_dotcom_chat.total_engaged_users,
        pull_requests_total_engaged_users: metric.copilot_dotcom_pull_requests.total_engaged_users,
        ide_code_completions_total_engaged_users: metric.copilot_ide_code_completions.total_engaged_users
      }
    end
  end
end
