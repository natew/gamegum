include ActionView::Helpers::SanitizeHelper

module ApplicationHelper
  # Works the same as link_to but wraps the link with an <li>
  # Adds the following options:
  #
  def li(*args)
    options         = args[1] || {}
    html_options    = args[2] || {}
    url             = url_for(options)
    active_options  = html_options.delete(:active) || {}

    if is_active_link?(url, active_options)
      css_class = ' class="active"'
    else
      if options.is_a?(Hash) and options.has_value?(:inactive_class)
        css_class = options[:inactive_class]
      else
        css_class = ''
      end
    end

    html_options[:class].blank? ? html_options.delete(:class) : html_options[:class].lstrip!

    raw "<li#{css_class}>#{link_to(args[0], options, html_options)}</li>"
  end

  def is_active_link?(url, options = {})
    case options[:when]
    when :self, nil
      !request.fullpath.match(/^#{Regexp.escape(url)}(\/?.*)?$/).blank?
    when :self_only
      !request.fullpath.match(/^#{Regexp.escape(url)}\/?(\?.*)?$/).blank?
    when Regexp
      !request.fullpath.match(options[:when]).blank?
    when Array
      controllers = options[:when][0]
      actions     = options[:when][1]
      (controllers.blank? || controllers.member?(params[:controller])) &&
      (actions.blank? || actions.member?(params[:action]))
    when TrueClass
      true
    when FalseClass
      false
    end
  end

  # Creates a new html definitions (<dt></dt><dd></dd>)
  def dt_dd(dt, dd)
    if dd.nil? or dd.empty?
      ''
    else
      "<dt>#{dt}</dt><dd>#{dd}</dd>".html_safe
    end
  end

  # Returns a formatted message for the chats
  def message_content(message)
    %(<li><span>#{message.created_at.strftime('%R')}</span> <strong>#{message.sender.nickname}</strong> #{message.content}</li>)
  end

  # Returns the html stars given to a game by a user.
  def stars_given(game, user, full = true)
    if game.rated_by? user
      rating = game.rating_by user
      return stars(rating, full)
    else
      return nil
    end
  end

  # Returns the html stars given to a game.
  def stars_for(game, full = true)
    rating = game.rating_avg
    return stars(rating, full)
  end

  # Given a number (num), returns that many highlighted html stars out of five max
  def stars(num, full = true)
    stars = ''
    for i in 1..5
      if     (num >= i)        then stars += image_tag('star.png')
      elsif  (num%1 > 0.35)   then stars += image_tag('starhalf.png')
      else                    stars += image_tag('starnull.png')
      end
    end
    return stars.html_safe
  end

  # Truncates the given text to the given length and appends truncate_string to the end if the text was truncated
  def truncate(text, options = {})
    length = options[:length] || 30
    truncate_string = options[:truncate_with] || "&hellip;".html_safe

    return if text.nil?
    text = (text.mb_chars.length > length) ? text[/\A.{#{length}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
    raw h(strip_tags(text))
  end

  # Returns time_ago_in_words within two weeks, otherwise formatted date
  def relative_time(date)
    begin
      return_date = date.to_time
      if (return_date > 2.weeks.ago)
        time_ago_in_words(return_date) + " ago"
      else
        return_date.strftime("%b #{return_date.day.ordinalize}, %Y")
      end
    rescue
      'pending'
    end
  end

  # Decides whether to use "a" or "an" if he next word is plural.
  # If keep_word is true, append the actual word
  def a_or_an(word, keep_word = false)
    (word =~ /^[aeiouh]/i ? "an " : "a ") + (keep_word ? word : "")
  end

  # For setting the html title of the site
  def yield_for(content_sym, default)
    output = content_for(content_sym)
    output = default if output.blank?
    output
  end
end
