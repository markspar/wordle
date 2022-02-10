# get starting word
$wordnikapikey = 'putyourapikeyhere'
$wordlen = '5'
$wordnikurl = 'https://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=true&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength='+$wordlen+'&maxLength='+$wordlen+'&api_key='+$wordnikapikey

try 
{
    $r = Invoke-WebRequest -Uri $wordnikurl -Method Get
    $result = ConvertFrom-Json -InputObject $r.Content
}
catch 
{
    throw $_
}
$answer=$result[0].word

# loop for 6 guesses
$l=1
Clear-Host
DO {
    # get guess word
    do {
        $guess = Read-Host "Guess $($l)"
        # validate guess is a word
        $wordnikurl = 'https://api.wordnik.com/v4/word.json/'+$guess+'/definitions?limit=200&includeRelated=false&sourceDictionaries=all&useCanonical=true&includeTags=false&api_key='+$wordnikapikey
        if ($guess.length -eq 5) {
            try 
            {
                $r = Invoke-WebRequest -Uri $wordnikurl -Method Get
                $result = ConvertFrom-Json -InputObject $r.Content
                if ($r.StatusCode -ne 200) { 
                    $guess = $null 
                    write-output "That wasn't a word!"
                }
            }
            catch 
            {
                $guess = $null
                write-output "That wasn't a word!"
            }
        }
        else {
            write-output "That wasn't 5 characters."
        }
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

if ($guess -ne $answer) { write-output "The word was $($answer)!" }
write-host "Thanks for playing!"
