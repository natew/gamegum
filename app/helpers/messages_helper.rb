## Helper for RESTful_Easy_Messages
module MessagesHelper

  # Dynamic label for the sender/receiver column in the messages.rhtml view
  def sender_or_receiver_label
    if params[:action] == "outbox"
      "Recipient"
    # Used for both inbox and trashbin
    else
      "Sender"
    end
  end

  # Checkbox for marking a message for deletion
  def delete_check_box(message)
    check_box_tag 'to_delete[]', message.id
  end

  # Link to view the message
  def link_to_message(message)
     link_to "#{h(subject_and_status(message))}".html_safe, message_path(message)
  end

  # Dynamic data for the sender/receiver column in the messages.rhtml view
  def sender_or_receiver(message)
    if params[:action] == "outbox"
      to_user_link(message)
    # Used for both inbox and trashbin
    else
      from_user_link(message)
    end
  end

  # Pretty format for message sent date/time
  def sent_at(message)
    h(message.created_at.to_date.strftime('%m/%d/%Y') + " " + message.created_at.strftime('%I:%M %p').downcase)
  end

  # Pretty format for message.subject which appeads the status (Deleted/Unread)
  def subject_and_status(message)
    tag = ''
    if message.receiver_deleted?
      tag = " (Deleted)"
    elsif message.read_at.nil? and params[:action] != "outbox"
       "&middot; <strong>#{message.subject}</strong>".html_safe
    else
      message.subject
    end
  end

  # Link to User for Message View
  def to_user_link(message)
    message.receiver ? link_to(message.receiver_name, user_path(message.receiver)) : ''
  end

  # Link from User for Message View
  def from_user_link(message)
    message.sender ? link_to(message.sender_name, user_path(message.sender)) : ''
  end

  # Reply Button
  def button_to_reply(message)
    button_to "Reply", reply_user_message_path(current_user, message), :method => :get
  end

  # Delete Button
  def button_to_delete(message)
    button_to "Delete", user_message_path(current_user, message), :confirm => "Are you sure?", :method => :delete
  end
end
