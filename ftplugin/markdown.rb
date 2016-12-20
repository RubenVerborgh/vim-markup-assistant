module Markdown

  # Toggles emphasis around the cursor
  def self.toggle_emphasis_at_cursor
    toggle_at_cursor '_'
  end

  # Toggles strong emphasis around the cursor
  def self.toggle_strong_at_cursor
    toggle_at_cursor '**'
  end

  # Toggles the given marker around the cursor
  def self.toggle_at_cursor marker
    buffer = VIM::Buffer.current
    window = VIM::Window.current

    line = buffer.line
    cursor = window.cursor
    cursor[1] = toggle_marker(line, cursor[1], marker)

    buffer.line = line
    window.cursor = cursor
  end

  # Toggles the marker at the given position in the text,
  # returning the updated position
  def self.toggle_marker text, pos, marker
    # Find a marked segment around the position
    segment_start = -1; segment_end = -1; content_start = -1
    loop do
      # Find the next start marker
      segment_start = text.index(marker, segment_end + 1)
      break if segment_start.nil?

      # Find the next end marker
      segment_end = text.index(marker, segment_start + marker.length) ||
                    (text.length + 1)
      segment_end += marker.length - 1

      # Stop if the position falls within the current segment
      break if pos.between?(segment_start, segment_end)

      # Find the start position of the content after the current segment
      content_start = segment_end + 1
    end

    # The position is not within a marked segment
    if segment_start.nil?
      # Create segment on surrounding word boundaries
      segment_start = text.rindex(/\W/, pos)
      segment_start = segment_start.nil? ? 0 : segment_start + 1
      segment_end = text.index(/\W/, pos)
      segment_end = segment_end.nil? ? text.length : segment_end - 1
      segment = segment_start..segment_end

      # If there is preceding segment only separated by whitespace
      if content_start >= 0 && text[content_start..(segment_start-1)] =~ /^\s$/
        # Join with the previous segment
        segment = (content_start-marker.length)..segment_end
        text[segment] = "#{text[content_start..segment_end]}#{marker}"
        pos -= marker.length
      else
        # Place markers around segment
        text[segment] = "#{marker}#{text[segment]}#{marker}"
        pos += marker.length
      end
    # The position is within a marked segment
    else
      # Remove markers around segment
      segment = segment_start..segment_end
      contents = (segment_start+marker.length)..(segment_end-marker.length)
      text[segment] = text[contents]
      pos = [segment_start, pos - marker.length].max
    end
  end

end
