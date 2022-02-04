# get starting word
$wordnikapikey = 'blahblah'
$wordlen = 5
$wordnikurl = 'https://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=true&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength='+$wordlen+'&maxLength='+$wordlen+'&api_key='+$wordnikapikey
#try 
#{
#    $r = Invoke-WebRequest -Uri $wordnikurl -Method Get
#    $result = ConvertFrom-Json -InputObject $r.Content
#}
#catch 
#{
#    throw $_
#}
# write-output $result
$answer='BADLY'

# loop for 6 guesses
$l=1
DO {
    # get guess word
    do {
        $guess = Read-Host "Guess $($l)"
        # validate guess is a word
    }
    while ($guess.length -ne 5)

    $tguess = $guess.toupper()
    $tanswer = $answer.toupper()

    # check green positions
    for ($i=0;$i -lt $tguess.Length;$i++) {
        if ($tanswer.ToCharArray()[$i] -eq $tguess.ToCharArray()[$i]) {
            $tanswer = $tanswer.Remove($i,1).insert($i," ")
            $tguess = $tguess.Remove($i,1).insert($i,2)
        }
    }

    # check yellow positions
    for ($i=0;$i -lt $tguess.Length;$i++) {
        $pos = $tanswer.IndexOf($tguess.ToCharArray()[$i])
        if ($pos -ne -1) {
            $tanswer = $tanswer.Remove($pos,1).insert($pos," ")
            $tguess = $tguess.Remove($i,1).insert($i,1)
        }
    # if not green or yellow, must be grey
        elseif ($tguess.ToCharArray()[$i] -ne "2") {
            $tguess = $tguess.Remove($i,1).insert($i,0)
        }
    }

#output how good the guess was
    write-host "         " -NoNewLine
    for ($i=0;$i -lt $answer.length;$i++) {

        switch($tguess.ToCharArray()[$i]) {
            "2" {write-host $($guess.ToCharArray()[$i]) -NoNewline -BackgroundColor Green -ForegroundColor White} #write in character in green
            "1" {write-host $guess.ToCharArray()[$i] -NoNewline -BackgroundColor Yellow -ForegroundColor White} #write in character in yellow
            "0" {write-host $guess.ToCharArray()[$i] -NoNewline -BackgroundColor Gray -ForegroundColor White} #write in character in grey
        }
    }
    write-host
    
    # if guess = target then show YOU WON! and end
    if ($guess -eq $answer) {
        write-host "***** YOU WON!!! *****" -ForegroundColor Red -BackgroundColor White
        break
    }

    # loop
    $l++
} while ($l -le 6)

write-host "Thanks for playing!"
