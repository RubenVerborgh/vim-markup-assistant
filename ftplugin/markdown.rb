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
    segment_start = nil; segment_end = -1; content_before = nil
    loop do
      # Find the next start marker before the position
      segment_start = text.index(marker, segment_end + 1)
      segment_start = nil if segment_start && segment_start > pos
      break if segment_start.nil? # no segment found

      # Find the next end marker
      segment_end = text.index(marker, segment_start + marker.length) ||
                    (text.length + 1)
      segment_end += marker.length - 1
      break if segment_end >= pos # segment found

      # Clear the segment
      segment_start = nil
      content_before = segment_end + 1
    end

    # The position is not within a marked segment
    if segment_start.nil?
      # Create segment on surrounding word boundaries
      segment_start = text.rindex(/\W/, pos)
      segment_start = segment_start.nil? ? 0 : segment_start + 1
      segment_end = text.index(/\W/, pos)
      segment_end = segment_end.nil? ? text.length : segment_end - 1

      # Set up markers
      start_marker = marker
      end_marker = marker

      # Join with previous segment if they are only separated by whitespace
      unless content_before.nil? || text[content_before..(segment_start-1)] =~ /\S/
        text[(content_before-marker.length)..(content_before-1)] = ''
        pos -= start_marker.length
        start_marker = ''
      end

      # Join with next segment if they are only separated by whitespace
      content_after = text.index(marker, segment_end + 1)
      unless content_after.nil? || text[(segment_end+1)..(content_after-1)] =~ /\S/
        text[content_after,marker.length] = ''
        end_marker = ''
      end

      # Place markers around segment
      segment = segment_start..segment_end
      text[segment] = "#{start_marker}#{text[segment]}#{end_marker}"
      pos += start_marker.length

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
