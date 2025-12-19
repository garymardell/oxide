module Oxide::Utils
  # Provides fuzzy matching suggestions using Levenshtein distance algorithm.
  # Used to generate "Did you mean?" messages for GraphQL errors.
  class SuggestionList
    MAX_SUGGESTIONS = 5

    # Returns up to 5 best matches from options based on Levenshtein distance.
    # Uses a threshold of 40% of input length to filter suggestions.
    def self.suggest(input : String, options : Array(String)) : Array(String)
      input_lower = input.downcase
      input_length = input.size
      threshold = (input_length * 0.4).to_i + 1

      suggestions = [] of {String, Int32}

      options.each do |option|
        distance = levenshtein_distance(input_lower, option.downcase, threshold)
        if distance <= threshold
          suggestions << {option, distance}
        end
      end

      # Sort by distance first, then alphabetically
      suggestions.sort_by! { |item| {item[1], item[0]} }
      
      # Return up to MAX_SUGGESTIONS
      suggestions.first(MAX_SUGGESTIONS).map(&.[0])
    end

    # Formats suggestions into a "Did you mean?" message.
    # Returns nil if no suggestions provided.
    def self.did_you_mean_message(suggestions : Array(String)) : String?
      return nil if suggestions.empty?

      case suggestions.size
      when 1
        %( Did you mean "#{suggestions[0]}"?)
      when 2
        %( Did you mean "#{suggestions[0]}" or "#{suggestions[1]}"?)
      else
        quoted = suggestions[0...-1].map { |s| %("#{s}") }
        %( Did you mean #{quoted.join(", ")}, or "#{suggestions[-1]}"?)
      end
    end

    # Calculates Levenshtein distance between two strings using a three-row rolling array.
    # Returns early if distance exceeds threshold for performance optimization.
    private def self.levenshtein_distance(a : String, b : String, threshold : Int32) : Int32
      return b.size if a.empty?
      return a.size if b.empty?

      a_len = a.size
      b_len = b.size

      # Use three-row rolling array for memory efficiency
      prev_prev_row = Array(Int32).new(b_len + 1, 0)
      prev_row = Array(Int32).new(b_len + 1, 0)
      curr_row = Array(Int32).new(b_len + 1, 0)

      # Initialize first row
      (0..b_len).each { |j| prev_row[j] = j }

      (0...a_len).each do |i|
        curr_row[0] = i + 1

        (0...b_len).each do |j|
          if a[i] == b[j]
            # Characters match - copy diagonal value
            curr_row[j + 1] = prev_row[j]
          else
            # Characters don't match - minimum of three operations + 1
            deletion = curr_row[j]
            insertion = prev_row[j + 1]
            substitution = prev_row[j]
            
            min_cost = deletion < insertion ? deletion : insertion
            min_cost = substitution if substitution < min_cost
            
            curr_row[j + 1] = min_cost + 1
          end
        end

        # Early exit if minimum value in current row exceeds threshold
        if curr_row.min > threshold
          return threshold + 1
        end

        # Rotate rows
        prev_prev_row, prev_row, curr_row = prev_row, curr_row, prev_prev_row
      end

      prev_row[b_len]
    end
  end
end
