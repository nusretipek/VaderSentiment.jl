using Test, JuliaVader

struct TestTuple
    sentence::AbstractString
    original_sentiment::Dict
end
    
test_set =  [TestTuple("VADER is smart, handsome, and funny.", Dict("neg"=> 0.0, "neu"=> 0.254, "pos"=> 0.746, "compound"=> 0.8316)),
             TestTuple("VADER is smart, handsome, and funny!", Dict("neg"=> 0.0, "neu"=> 0.248, "pos"=> 0.752, "compound"=> 0.8439)),
             TestTuple("VADER is very smart, handsome, and funny.", Dict("neg"=> 0.0, "neu"=> 0.299, "pos"=> 0.701, "compound"=> 0.8545)),
             TestTuple("VADER is VERY SMART, handsome, and FUNNY.", Dict("neg"=> 0.0, "neu"=> 0.246, "pos"=> 0.754, "compound"=> 0.9227)),
             TestTuple("VADER is VERY SMART, handsome, and FUNNY!!!", Dict("neg"=> 0.0, "neu"=> 0.233, "pos"=> 0.767, "compound"=> 0.9342)),
             TestTuple("VADER is VERY SMART, uber handsome, and FRIGGIN FUNNY!!!", Dict("neg"=> 0.0, "neu"=> 0.294, "pos"=> 0.706, "compound"=> 0.9469)),
             TestTuple("VADER is not smart, handsome, nor funny.", Dict("neg"=> 0.646, "neu"=> 0.354, "pos"=> 0.0, "compound"=> -0.7424)),
             TestTuple("The book was good.", Dict("neg"=> 0.0, "neu"=> 0.508, "pos"=> 0.492, "compound"=> 0.4404)),
             TestTuple("At least it isn't a horrible book.", Dict("neg"=> 0.0, "neu"=> 0.678, "pos"=> 0.322, "compound"=> 0.431)),
             TestTuple("The book was only kind of good.", Dict("neg"=> 0.0, "neu"=> 0.697, "pos"=> 0.303, "compound"=> 0.3832)),
             TestTuple("The plot was good, but the characters are uncompelling and the dialog is not great.", Dict("neg"=> 0.327, "neu"=> 0.579, "pos"=> 0.094, "compound"=> -0.7042)),
             TestTuple("Today SUX!", Dict("neg"=> 0.779, "neu"=> 0.221, "pos"=> 0.0, "compound"=> -0.5461)),
             TestTuple("Today only kinda sux! But I'll get by, lol", Dict("neg"=> 0.127, "neu"=> 0.556, "pos"=> 0.317, "compound"=> 0.5249)),
             TestTuple("Make sure you :) or :D today!", Dict("neg"=> 0.0, "neu"=> 0.294, "pos"=> 0.706, "compound"=> 0.8633)),
             TestTuple("Catch utf-8 emoji such as such as 💘 and 💋 and 😁", Dict("neg"=> 0.0, "neu"=> 0.615, "pos"=> 0.385, "compound"=> 0.875)),
             TestTuple("Not bad at all", Dict("neg"=> 0.0, "neu"=> 0.513, "pos"=> 0.487, "compound"=> 0.431)),
             TestTuple("Not GREATLY bad at all!!!!!", Dict("neg"=> 0.0, "neu"=> 0.456, "pos"=> 0.544, "compound"=> 0.6982)),
             TestTuple("Not GREATLY bad at all??", Dict("neg"=> 0.0, "neu"=> 0.502, "pos"=> 0.498, "compound"=> 0.6084)),
             TestTuple("Not GREATLY bad at all????", Dict("neg"=> 0.0, "neu"=> 0.467, "pos"=> 0.533, "compound"=> 0.6777)),
             TestTuple("Not least GREATLY bad at all????", Dict("neg"=> 0.0, "neu"=> 0.523, "pos"=> 0.477, "compound"=> 0.6777)),
             TestTuple("Not GREATLY least bad at all????", Dict("neg"=> 0.436, "neu"=> 0.564, "pos"=> 0.0, "compound"=> -0.5944)),
             TestTuple("Catch utf-8 emoji such as such as💘 and 💋 and 😁", Dict("neg"=> 0.0, "neu"=> 0.615, "pos"=> 0.385, "compound"=> 0.875)),
             TestTuple("least bad at all????", Dict("neg"=> 0.0, "neu"=> 0.441, "pos"=> 0.559, "compound"=> 0.5873)),
             TestTuple("No not GREATLY least bad at all????", Dict("neg"=> 0.548, "neu"=> 0.452, "pos"=> 0.0, "compound"=> -0.7238)),
             TestTuple("The book was only kind of no good.", Dict("neg"=> 0.381, "neu"=> 0.619, "pos"=> 0.0, "compound"=> -0.4017)),
             TestTuple("The book was only kind of bad ass good.", Dict("neg"=> 0.246, "neu"=> 0.422, "pos"=> 0.331, "compound"=> 0.0534)),
             TestTuple("The book was only kind of never so bad ass good.", Dict("neg"=> 0.0, "neu"=> 0.516, "pos"=> 0.484, "compound"=> 0.7579)),
             TestTuple("The book was only kind of without doubt bad ass good.", Dict("neg"=> 0.0, "neu"=> 0.412, "pos"=> 0.588, "compound"=> 0.8406)),
             TestTuple("The book was only kind of badn't ass good.", Dict("neg"=> 0.196, "neu"=> 0.571, "pos"=> 0.233, "compound"=> 0.1139)),
             TestTuple("I am a big happy cat.", Dict("neg"=> 0.0, "neu"=> 0.575, "pos"=> 0.425, "compound"=> 0.5719))]

analyzer = JuliaVader.SentimentIntensityAnalyzer

@testset "Test Vader Sentiment" begin
    for test_case in test_set
        @test (analyzer(test_case.sentence).polarity_scores) == test_case.original_sentiment end end
