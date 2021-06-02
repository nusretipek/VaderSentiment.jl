#Declaration of GLOBALS

const global B_INCR = 0.293
const global B_DECR = -0.293
const global C_INCR = 0.733
const global N_SCALAR = -0.74
const global NORMALIZATION_ALPHA = 15.0

NEGATION_TOKENS = ["aint", "arent", "cannot", "cant", "couldnt", "darent", "didnt", "doesnt",
                   "ain't", "aren't", "can't", "couldn't", "daren't", "didn't", "doesn't",
                   "dont", "hadnt", "hasnt", "havent", "isnt", "mightnt", "mustnt", "neither",
                   "don't", "hadn't", "hasn't", "haven't", "isn't", "mightn't", "mustn't",
                   "neednt", "needn't", "never", "none", "nope", "nor", "not", "nothing", "nowhere",
                   "oughtnt", "shant", "shouldnt", "uhuh", "wasnt", "werent",
                   "oughtn't", "shan't", "shouldn't", "uh-uh", "wasn't", "weren't",
                   "without", "wont", "wouldnt", "won't", "wouldn't", "rarely", "seldom", "despite"]

BOOSTER_DICT = Dict("absolutely"=> B_INCR, "amazingly"=> B_INCR, "awfully"=> B_INCR, 
                    "completely"=> B_INCR, "considerable"=> B_INCR, "considerably"=> B_INCR,
                    "decidedly"=> B_INCR, "deeply"=> B_INCR, "effing"=> B_INCR, "enormous"=> B_INCR, "enormously"=> B_INCR,
                    "entirely"=> B_INCR, "especially"=> B_INCR, "exceptional"=> B_INCR, "exceptionally"=> B_INCR, 
                    "extreme"=> B_INCR, "extremely"=> B_INCR,"fabulously"=> B_INCR, "flipping"=> B_INCR, "flippin"=> B_INCR, 
                    "frackin"=> B_INCR, "fracking"=> B_INCR, "fricking"=> B_INCR, "frickin"=> B_INCR, "frigging"=> B_INCR, 
                    "friggin"=> B_INCR, "fully"=> B_INCR, "fuckin"=> B_INCR, "fucking"=> B_INCR, "fuggin"=> B_INCR, "fugging"=> B_INCR,
                    "greatly"=> B_INCR, "hella"=> B_INCR, "highly"=> B_INCR, "hugely"=> B_INCR, "incredible"=> B_INCR, 
                    "incredibly"=> B_INCR, "intensely"=> B_INCR, "major"=> B_INCR, "majorly"=> B_INCR, "more"=> B_INCR, "most"=> B_INCR, 
                    "particularly"=> B_INCR, "purely"=> B_INCR, "quite"=> B_INCR, "really"=> B_INCR, "remarkably"=> B_INCR, 
                    "so"=> B_INCR, "substantially"=> B_INCR, "thoroughly"=> B_INCR, "total"=> B_INCR, "totally"=> B_INCR, 
                    "tremendous"=> B_INCR, "tremendously"=> B_INCR, "uber"=> B_INCR, "unbelievably"=> B_INCR, 
                    "unusually"=> B_INCR, "utter"=> B_INCR, "utterly"=> B_INCR, "very"=> B_INCR, "almost"=> B_DECR, 
                    "barely"=> B_DECR, "hardly"=> B_DECR, "just enough"=> B_DECR, "kind of"=> B_DECR, "kinda"=> B_DECR, 
                    "kindof"=> B_DECR, "kind-of"=> B_DECR, "less"=> B_DECR, "little"=> B_DECR, "marginal"=> B_DECR, 
                    "marginally"=> B_DECR, "occasional"=> B_DECR, "occasionally"=> B_DECR, "partly"=> B_DECR, 
                    "scarce"=> B_DECR, "scarcely"=> B_DECR, "slight"=> B_DECR, "slightly"=> B_DECR, "somewhat"=> B_DECR, 
                    "sort of"=> B_DECR, "sorta"=> B_DECR, "sortof"=> B_DECR, "sort-of"=> B_DECR)

SPECIAL_CASES = Dict("the shit"=> 3, "the bomb"=> 3, "bad ass"=> 1.5, "badass"=> 1.5, 
                     "bus stop"=> 0.0, "yeah right"=> -2, "kiss of death"=> -1.5,
                     "to die for"=> 3, "beating heart"=> 3.1, "broken heart"=> -2.9)

#STRUCTS

struct SentiText
    text;words_and_emoticons;is_cap_diff
    function _strip_punc_if_word(token)
        stripped_temp = replace(token, r"[[:punct:]]+$" => "")
        stripped = replace(stripped_temp, r"^[[:punct:]]+" => "")
        if (length(stripped) <= 2)
            return token
        else
            return stripped
        end
    end
    function _words_and_emoticons(text)
        words = split(text, r"\s+")
        stripped = map(_strip_punc_if_word, words)
        return stripped
    end
    function SentiText(text)
        if (typeof(text) != String)
            text = string(text)
        end
        temp_words_and_emoticons = _words_and_emoticons(text)
        new(text, temp_words_and_emoticons, allcap_differential(temp_words_and_emoticons))
    end
    function allcap_differential(words::Array)
        allcap_words = 0
        for word in words
            if ((length(replace(word, r"[^A-Za-z]" => "")) > 0) && all(isuppercase, collect(replace(word, r"[^A-Za-z]" => ""))))
                allcap_words += 1
            end
        end
        cap_differential = size(words)[1] - allcap_words
        if (0 < cap_differential && cap_differential < size(words)[1])
            return true
        else
            return false
        end
    end
end

mutable struct SentimentIntensityAnalyzer
    polarity_scores::Dict{<:AbstractString ,<:Float64}
    
    #Read Lexicons
    function read_file(InputFile::AbstractString)
        f = open(InputFile)
        file_lines = readlines(f)
        close(f)
        return file_lines
    end
    function lex_dict(file::AbstractString)
        lex_dict = Dict{String, Float64}()
        for j in read_file(file)
            push!(lex_dict, split(j, "\t")[1] => parse(Float64, split(j, "\t")[2])) end
        return lex_dict
    end

    function emoji_dict(file::AbstractString)
        emoji_dict = Dict{String, String}()
        for j in read_file(file)
            push!(emoji_dict, split(j, "\t")[1] => split(j, "\t")[2]) end
        return emoji_dict
    end
    
    lexicon_dictionary = lex_dict(joinpath(dirname(pathof(VaderSentiment)), "lexicons", "vader_lexicon.txt"))
    emoji_dictionary = emoji_dict(joinpath(dirname(pathof(VaderSentiment)), "lexicons", "emoji_utf8_lexicon.txt"))
    
    function is_negated(input_words::Array, include_nt::Bool = true)
        input_words = [lowercase(string(i)) for i in input_words]
        for word in NEGATION_TOKENS
            if (word in input_words) 
                return true end
        end
        if (include_nt)
            for word in input_words
                if occursin("n't", word) 
                    return true end
            end
        end
        return false
    end

    function normalize(score::Real)
        norm_score = score/sqrt((score*score)+NORMALIZATION_ALPHA)
        if (norm_score < -1.0)
            return -1.0
        elseif (norm_score > 1.0)
            return 1.0
        else
            return norm_score 
        end
    end

    function allcap_differential(words::Array)
        allcap_words = 0
        for word in words
            if ((length(replace(word, r"[^A-Za-z]" => "")) > 0) && all(isuppercase, collect(replace(word, r"[^A-Za-z]" => ""))))
                allcap_words += 1
            end
        end
        cap_differential = size(words)[1] - allcap_words
        if (0 < cap_differential && cap_differential < size(words)[1])
            return true
        else
            return false
        end
    end

    function scalar_inc_dec(word::AbstractString, valence::Real, has_mixed_caps::Bool)
        scalar = 0.0
        word_lower = lowercase(word)
        if (word_lower in collect(keys(BOOSTER_DICT)))
            scalar = BOOSTER_DICT[word_lower]
            if (valence < 0)
                scalar *= -1
            end
            if ((length(replace(word, r"[^A-Za-z]" => "")) > 0) && all(isuppercase, collect(replace(word, r"[^A-Za-z]" => ""))) && has_mixed_caps)
                if (valence > 0)
                    scalar += C_INCR
                else
                    scalar -= C_INCR
                end
            end
        end
        return scalar
    end
    #Calculate Polarity Scores
    function _least_check(valence::Real, words_and_emoticons::Array, i::Integer)
        if (i > 2 && !(lowercase(words_and_emoticons[i - 1]) in collect(keys(lexicon_dictionary))) && lowercase(words_and_emoticons[i - 1]) == "least")
            if (lowercase(words_and_emoticons[i - 2]) != "at" && lowercase(words_and_emoticons[i - 2]) != "very")
                valence = valence * N_SCALAR
            end
        elseif (i > 1 && !(lowercase(words_and_emoticons[i - 1]) in collect(keys(lexicon_dictionary))) && lowercase(words_and_emoticons[i - 1]) == "least")
            valence = valence * N_SCALAR
        end
        return valence
    end

    function _but_check(words_and_emoticons::Array, sentiments::Array)
        words_and_emoticons_lower = [lowercase(string(s)) for s in words_and_emoticons]
        if ("but" in words_and_emoticons_lower)
            but_index = findfirst(x -> x == "but", words_and_emoticons_lower)
            for sentiment in sentiments
                sentiment_index = findfirst(x -> x == sentiment, sentiments)
                if (sentiment_index < but_index)
                    deleteat!(sentiments, sentiment_index)
                    insert!(sentiments, sentiment_index, sentiment*0.5)
                elseif (sentiment_index > but_index)
                    deleteat!(sentiments, sentiment_index)
                    insert!(sentiments, sentiment_index, sentiment*1.5)
                end
            end
        end
        return sentiments
    end

    function _special_idioms_check(valence::Real, words_and_emoticons::Array, i::Integer)
        words_and_emoticons_lower = [lowercase(string(s)) for s in words_and_emoticons]
        onezero = words_and_emoticons_lower[i-1] * " " * words_and_emoticons_lower[i]
        twoonezero = words_and_emoticons_lower[i-2] * " " * words_and_emoticons_lower[i-1] * " " * words_and_emoticons_lower[i]
        twoone = words_and_emoticons_lower[i-2] * " " * words_and_emoticons_lower[i-1]
        threetwoone = words_and_emoticons_lower[i-3] * " " * words_and_emoticons_lower[i-2] * " " * words_and_emoticons_lower[i-1]
        threetwo = words_and_emoticons_lower[i-3] * " " * words_and_emoticons_lower[i-2]
        sequences = [onezero, twoonezero, twoone, threetwoone, threetwo]
        for sequence in sequences
            if sequence in collect(keys(SPECIAL_CASES))
                valence = SPECIAL_CASES[sequence]
                break
            end
        end
        if (size(words_and_emoticons_lower)[1]-1 > i)
            zeroone = words_and_emoticons_lower[i] * " " * words_and_emoticons_lower[i+1]
            if zeroone in collect(keys(SPECIAL_CASES))
                valence = SPECIAL_CASES[zeroone]
            end
        end
        if (size(words_and_emoticons_lower)[1]-1 > i+1)
            zeroonetwo = words_and_emoticons_lower[i] * " " * words_and_emoticons_lower[i+1] * " " * words_and_emoticons_lower[i+2]
            if zeroonetwo in collect(keys(SPECIAL_CASES))
                valence = SPECIAL_CASES[zeroonetwo]
            end
        end
        n_grams = [threetwoone, threetwo, twoone]
        for n_gram in n_grams
            if n_gram in collect(keys(BOOSTER_DICT))
                valence += BOOSTER_DICT[n_gram]
            end
        end
        return valence
    end

    function _amplify_ep(text::AbstractString)
        c = count(x->(x=='!'), text)
        if (c > 4) 
            return 4 * 0.292
        else
            return c * 0.292
        end
    end

    function _amplify_qm(text::AbstractString)
        q = count(x->(x=='?'), text)
        if (q > 1 && q <= 3) 
            return q * 0.18
        elseif (q > 1) 
            return 0.96
        else
            return 0
        end
    end

    function _punctuation_emphasis(text::AbstractString)
        return _amplify_ep(text) + _amplify_qm(text)
    end

    function _sift_sentiment_scores(sentiments::Array)
        positive_sum = 0.0
        negative_sum = 0.0
        neutral_count = 0
        for sentiment_score in sentiments
            if (sentiment_score > 0)
                positive_sum += (sentiment_score + 1)
            end
            if (sentiment_score < 0)
                negative_sum += (sentiment_score - 1)
            end
            if (sentiment_score == 0)
                neutral_count += 1
            end
        end
        return positive_sum, negative_sum, neutral_count
    end

    function score_valence(sentiments::Array, text::AbstractString)
        if (size(sentiments)[1] > 0)
            sum_s = sum(sentiments)
            if (sum_s > 0)
                sum_s += _punctuation_emphasis(text)
            elseif (sum_s < 0)
                sum_s -= _punctuation_emphasis(text)
            end
            compound = normalize(sum_s)
            pos_sum, neg_sum, neu_count = _sift_sentiment_scores(sentiments)
            if (pos_sum > abs(float(neg_sum)))
                pos_sum += _punctuation_emphasis(text)
            elseif (pos_sum < abs(float(neg_sum)))
                neg_sum -= _punctuation_emphasis(text)
            end
            total = pos_sum + abs(float(neg_sum)) + neu_count
            pos = abs(float(pos_sum / total))
            neg = abs(float(neg_sum / total))
            neu = abs(float(neu_count / total))
        else
            compound = 0.0
            pos = 0.0
            neg = 0.0
            neu = 0.0
        end
        sentiment_dict = Dict("neg"=> round(neg, digits = 3),
                              "neu"=> round(neu, digits = 3),
                              "pos"=> round(pos, digits = 3),
                              "compound"=> round(compound, digits = 4))
        return sentiment_dict
    end

    function _negation_check(valence::Real, words_and_emoticons::Array, start_i::Integer, i::Integer)
        words_and_emoticons_lower = [lowercase(string(s)) for s in words_and_emoticons] 
        if (start_i == 1)
            if (is_negated([words_and_emoticons_lower[i - (start_i)]])) 
                valence *= N_SCALAR
            end
        end
        if (start_i == 2)
            if (words_and_emoticons_lower[i-2] == "never" && (words_and_emoticons_lower[i-1] == "so" || words_and_emoticons_lower[i-1] == "this"))
                valence *= 1.25
            elseif (words_and_emoticons_lower[i-2] == "without" && words_and_emoticons_lower[i-1] == "doubt")
                valence = valence
            elseif is_negated([words_and_emoticons_lower[i - (start_i)]])
                valence *= N_SCALAR
            end
        end
        if (start_i == 3)
            if (words_and_emoticons_lower[i-3] == "never" && (words_and_emoticons_lower[i-2] == "so" || words_and_emoticons_lower[i-2] == "this") || (words_and_emoticons_lower[i-1] == "so" || words_and_emoticons_lower[i - 1] == "this"))
                valence *= 1.25
            elseif (words_and_emoticons_lower[i-3] == "without" && (words_and_emoticons_lower[i-2] == "doubt" || words_and_emoticons_lower[i-1] == "doubt"))
                valence = valence
            elseif is_negated([words_and_emoticons_lower[i - (start_i)]])
                valence *= N_SCALAR
            end
        end
        return valence
    end

    function sentiment_valence(valence::Real, sentitext::SentiText, item::AbstractString, i::Integer, sentiments::Array)
        is_cap_diff = sentitext.is_cap_diff
        words_and_emoticons = sentitext.words_and_emoticons
        item_lowercase = lowercase(item)
        if (item_lowercase in collect(keys(lexicon_dictionary)))
            valence = lexicon_dictionary[item_lowercase]
            if (item_lowercase == "no" && i != size(words_and_emoticons)[1] && lowercase(words_and_emoticons[i+1]) in collect(keys(lexicon_dictionary)))
                valence = 0.0
            end
            if ((i > 1 && lowercase(words_and_emoticons[i - 1]) == "no") || (i > 2 && lowercase(words_and_emoticons[i - 2]) == "no") || (i > 3 && lowercase(words_and_emoticons[i - 3]) == "no" && lowercase(words_and_emoticons[i - 1]) in ["or", "nor"]))
                valence = lexicon_dictionary[item_lowercase] * N_SCALAR
            end

            if ((length(replace(item, r"[^A-Za-z]" => "")) > 0) && all(isuppercase, collect(replace(item, r"[^A-Za-z]" => ""))) && is_cap_diff)
                if (valence > 0)
                    valence += C_INCR
                else
                    valence -= C_INCR
                end
            end

            for start_i in 1:3
                if (i > start_i && !(lowercase(words_and_emoticons[i - (start_i)]) in collect(keys(lexicon_dictionary))))
                    s = scalar_inc_dec(words_and_emoticons[i - (start_i)], valence, is_cap_diff)
                    if (start_i == 2 && s != 0)
                        s *= 0.95
                    end
                    if (start_i == 3 && s != 0)
                        s *= 0.9
                    end
                    valence += s
                    valence = _negation_check(valence, words_and_emoticons, start_i, i)
                    if (start_i == 3)
                        valence = _special_idioms_check(valence, words_and_emoticons, i)
                    end
                end
            end
            valence = _least_check(valence, words_and_emoticons, i)

        end
        push!(sentiments, valence)
        return sentiments
    end

    function polarity_scores(text::AbstractString)
        text_no_emoji = ""
        prev_space = true
        for chr in split(text, "")
            if chr in collect(keys(emoji_dictionary))
                description = emoji_dictionary[chr]
                if (!prev_space)
                    text_no_emoji *= " "
                end
                text_no_emoji *= description
                prev_space = false
            else
                text_no_emoji *= chr
                prev_space = (chr == " ")
            end
        end
        text = strip(text_no_emoji)
        sentitext = SentiText(text)

        sentiments = []
        words_and_emoticons = sentitext.words_and_emoticons
        for (i, item) in enumerate(words_and_emoticons)
            valence = 0
            if lowercase(item) in collect(keys(BOOSTER_DICT))
                push!(sentiments, valence)
                continue
            end           
            if (i < size(words_and_emoticons)[1]-1 && lowercase(item) == "kind" && lowercase(words_and_emoticons[i+1]) == "of")
                push!(sentiments, valence)
                continue
            end
            sentiments = sentiment_valence(valence, sentitext, item, i, sentiments)
        end

        sentiments = _but_check(words_and_emoticons, sentiments)
        valence_dict = score_valence(sentiments, text)
        return valence_dict
    end
    
    function SentimentIntensityAnalyzer(text::AbstractString)
        new(polarity_scores(text))
    end
end
