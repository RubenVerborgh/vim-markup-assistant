module Markdown
  WORD_BOUNDARY = /[*_.,;!¡¿?  \t\n\r\v\f]/

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
    # Get current line and cursor
    buffer = VIM::Buffer.current
    window = VIM::Window.current
    line = buffer.line
    cursor = window.cursor

    # Determine new line and cursor
    # (Vim uses byte position; Ruby uses character position)
    column = byte_pos_to_char_pos(line, cursor[1])
    column = toggle_marker(line, column, marker)
    cursor[1] = char_pos_to_byte_pos(line, column)

    # Set new line and cursor
    buffer.line = line
    window.cursor = cursor
  end

  # Toggles the marker at the given position in the text,
  # returning the updated position
  def self.toggle_marker text, pos, marker
    # Find a marked segment around the position
    segment_start = nil; segment_end = -1; prev_segment_end = text.length
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
      prev_segment_end = segment_end
    end

    # The position is not within a marked segment
    if segment_start.nil?
      # Create segment on surrounding word boundaries
      segment_start = text.rindex(WORD_BOUNDARY, [0, pos - 1].max)
      segment_start = segment_start.nil? ? 0 : segment_start + 1
      segment_end = text.index(WORD_BOUNDARY, pos + 1)
      segment_end = segment_end.nil? ? text.length : segment_end - 1

      # Set up markers
      start_marker = marker
      end_marker = marker

      # Join with previous segment if they are only separated by whitespace
      prev_content = (prev_segment_end + 1)..(segment_start - 1)
      if text[prev_content] =~ /^\s*$/
        text[(prev_content.begin-marker.length)..prev_segment_end] = ''
        pos -= marker.length
        segment_end -= marker.length
        start_marker = ''
      end

      # Join with next segment if they are only separated by whitespace
      next_segment_start = text.index(marker, segment_end + 1) || 0
      next_content = (segment_end + 1)..(next_segment_start - 1)
      if text[next_content] =~ /^\s*$/
        text[next_segment_start,marker.length] = ''
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
      contents = (segment_start + marker.length)..(segment_end - marker.length)
      text[segment] = text[contents]
      pos = [segment_start, pos - marker.length].max
      pos = [pos,  contents.end - marker.length].min
    end
  end

  # Converts a string position in bytes to a string position in characters
  def self.byte_pos_to_char_pos string, byte_pos
    string.length.times do |char_pos|
      return char_pos if string[0,char_pos].bytesize >= byte_pos
    end
  end

  # Converts a string position in characters to a string position in bytes
  def self.char_pos_to_byte_pos string, char_pos
    string[0,char_pos].bytesize
  end

end
