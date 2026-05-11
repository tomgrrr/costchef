module ApplicationHelper
  include Pagy::Frontend

  # Returns the candidate path if it's a safe internal URL, else the default.
  # Anti open-redirect: only accepts relative paths starting with a single "/"
  # and rejects protocol-relative URLs and backslash escape tricks.
  def safe_back_path(candidate, default)
    return default unless candidate.is_a?(String) && candidate.present?
    return default unless candidate.start_with?('/')
    return default if candidate.start_with?('//')
    return default if candidate.include?('\\')
    return default if candidate.match?(/[[:cntrl:]]/)

    candidate
  end
end
