#!/usr/bin/env ruby
require_relative '../ftplugin/markdown'
require 'test/unit'

class TestMarkdown < Test::Unit::TestCase
public
  def test_surround_one_word
    compare_toggle_marker 'abc def ghi',     5, '**',
                          'abc **def** ghi', 7
  end

  def test_surround_one_word_ignores_previous_markup
    compare_toggle_marker '**ab** c def ghi',      9, '**',
                          '**ab** c **def** ghi', 11
  end

  def test_surround_one_word_ignores_following_markup
    compare_toggle_marker 'abc def g **hi**',     5, '**',
                          'abc **def** g **hi**', 7
  end

  def test_unsurround_one_word
    compare_toggle_marker 'abc **def** ghi', 7, '**',
                          'abc def ghi',     5
  end

  def test_unsurround_two_words
    compare_toggle_marker 'abc **def ghi** foo', 7, '**',
                          'abc def ghi foo',     5
  end

  def test_unsurround_two_words_with_cursor_on_marker
    compare_toggle_marker 'abc **def ghi** foo', 4, '**',
                          'abc def ghi foo',     4
  end

  def test_unsurround_without_end
    compare_toggle_marker 'abc **def ghi', 7, '**',
                          'abc def ghi',   5
  end

  def test_surround_in_presence_of_previous_segment
    compare_toggle_marker 'abc **def**  ghi', 13, '**',
                          'abc **def  ghi**', 11
  end

  def test_surround_in_presence_of_following_segment
    compare_toggle_marker 'abc def  **ghi** jkl', 4, '**',
                          'abc **def  ghi** jkl', 6
  end

  def test_surround_in_presence_of_previous_and_following_segments
    compare_toggle_marker 'abc **abc** def   **ghi** jkl', 12, '**',
                          'abc **abc def   ghi** jkl', 10
  end

private
  def compare_toggle_marker input, input_pos, marker, expected_output, expected_output_pos
    output = input
    output_pos = Markdown.toggle_marker(output, input_pos, marker)
    assert_equal expected_output, output
    assert_equal output + "\n" + (" " * expected_output_pos) + "^",
                 output + "\n" + (" " * output_pos         ) + "^"
  end
end
