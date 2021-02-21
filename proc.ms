export('autoquiz.answer', '')
export('autoquiz.question_message', '')
export('autoquiz.question_math_message', '')
export('autoquiz.question_type', '')
export('autoquiz.question_answer', '')
export('autoquiz.reward', 0)
export('autoquiz.status', 0)
export('autoquiz.settime', 0)
export('autoquiz.chance', 0)
export('autoquiz.proverb.ko', split('\n', comp_read('proverb_ko.txt')))
export('autoquiz.proverb.en', split('\n', comp_read('proverb_en.txt')))

export('autoquiz.process_user', array())
proc _getUser() { return(import('autoquiz.process_user')) }
proc _addUser(@value){
    @array = import('autoquiz.process_user')
    array_push(@array, @value)
    export('autoquiz.process_user', @array)
}
proc _initUser() { export('autoquiz.process_user', array()) }

if (import('autoquiz.settime') == 0) { export('autoquiz.settime', time() + 1500000) }

proc _initQuiz(){
    export('autoquiz.status', 0)
    _initUser()
}

set_interval(1000, closure(){
    @prefix = _chprefix('e')
    @rand = rand(1500000,1800000)
    if (import('autoquiz.status') == 2) {
        if (time() >= import('autoquiz.settime')) {
            broadcast(@prefix'끝! '.array_size(_getUser()).'명이 참여해주셨습니다.')
            export('autoquiz.settime', time() + @rand) // 25분 ~ 30분 (UNIX time with nano second)
            _initQuiz()
        }
    } else {
        if (time() >= import('autoquiz.settime')) {
            if (import('autoquiz.status') == 1) {
                export('autoquiz.settime', time() + @rand) // 25분 ~ 30분 (UNIX time with nano second)
                _initQuiz()
                broadcast('')
                @type = import('autoquiz.question_type')
                if (@type == 'math'){
                    broadcast(@prefix.' '.import('autoquiz.question_math_message').' = '.import('autoquiz.question_answer'))
                } else if (@type == 'math2') {
                    broadcast(@prefix.' '.import('autoquiz.question_math_message'))
                } else if (@type == 'kor_hidden_word_match') {
                    broadcast(@prefix.' "§f'.import('autoquiz.question_answer').'§7"')
                }
                broadcast(@prefix'§7정답자가 없어 문제가 취소됩니다.')
                broadcast('')
                exit()
            }

            export('autoquiz.settime', time() + @rand)
            export('autoquiz.status', 1)

            switch(rand(1,8)) {
                case 1..2:
                    @chance = 1
                case 3..4:
                    @chance = 2
                case 5..6:
                    @chance = 3
                case 7..8:
                    @chance = 4
            }
            export('autoquiz.chance', @chance)

            if (@chance == 4) {
                @proverb = import('autoquiz.proverb.en')
                @cur_proverb = @proverb[array_rand(@proverb)[0]]

                @reward = rand(13,18)
                export('autoquiz.question_message', @cur_proverb)
                export('autoquiz.question_type', 'eng_typing_test')
                export('autoquiz.question_answer', @cur_proverb)
                export('autoquiz.reward', @reward)
                broadcast('')
                broadcast(@prefix '다음의 문장을 채팅창에 빠르게 입력하세요!')
                broadcast(@prefix '"§f'.@cur_proverb.'§7"')
                broadcast('')
            } else if (@chance == 3) {
                @proverb = import('autoquiz.proverb.ko')
                @cur_proverb = @proverb[array_rand(@proverb)[0]]

                @reward = rand(13,18)
                export('autoquiz.question_message', @cur_proverb)
                export('autoquiz.question_type', 'kor_typing_test')
                export('autoquiz.question_answer', @cur_proverb)
                export('autoquiz.reward', @reward)
                broadcast('')
                broadcast(@prefix '다음의 문장을 채팅창에 빠르게 입력하세요!')
                broadcast(@prefix '"§f'.@cur_proverb.'§7"')
                broadcast('')
            } else if (@chance == 2) {
                @proverb = import('autoquiz.proverb.ko')
                @cur_proverb = @proverb[array_rand(@proverb)[0]]
                @array_cur_proverb = split(' ', @cur_proverb)
                @length = ceil(divide(array_size(@array_cur_proverb), 4))
                @indexs = array_rand(@array_cur_proverb, @length)
                @answer = array()
                @length = 1 // 하나 고정
                for (assign(@i, 0), @i < @length, @i++) {
                    @cur = @array_cur_proverb[@indexs[@i]]
                    // @array_cur_proverb[@indexs[@i]] = reg_replace('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', 'ㅁ', @cur)
                    // if(reg_count('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', @cur) != length(@cur)) {
                    // }
                    @str = ''
                    @bo = false
                    
                    for (assign(@n, 0), @n < length(@cur), @n++) {
                        @cc = substr(@cur, @n, @n+1)
                        if (@cc != ',') {
                            @str = @str.'＃'
                        } else {
                            @str = @str.','
                            @bo = true
                        }
                    }

                    if (@bo) {
                        array_push(@answer, substr(@cur, 0, length(@cur) - 1))
                    } else {
                        array_push(@answer, @cur)
                    }
                    @array_cur_proverb[@indexs[@i]] = @str
                }

                // for (assign(@i, 0), @i < array_size(@array_cur_proverb), @i++) {
                //     @cur = @array_cur_proverb[@i].','
                //     msg('run' @cur reg_match_all('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', @cur) reg_count('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', @cur) length(@cur))
                //     @r_temp[@i] = reg_replace('[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]', 'ㅁ', @cur)
                // }

                // msg(_chprefix('a')@array_cur_proverb)
                // msg(_chprefix('a')' 'split('\n', comp_read('proverb_ko.txt')))
                // msg(_chprefix('a')' 'all_materials())

                @message = ''
                foreach(@s in @array_cur_proverb) {
                    if (@s == ' ') {
                        continue();
                    }
                    @message = @message.' '.@s
                }
                // @answer_m = ''
                // foreach(@s in @answer) {
                //     @answer_m = @answer_m.' '.@s
                // }
                if (substr(@message, 0, 1) == ' ') {
                    @message = substr(@message, 1, length(@message))
                }
                @reward = rand(15,20)
                export('autoquiz.question_message', @message)
                export('autoquiz.question_type', 'kor_hidden_word_match')
                export('autoquiz.question_answer', @answer[0])
                export('autoquiz.reward', @reward)
                broadcast('')
                broadcast(@prefix '다음 중 빈 문장의 문장을 채팅에 입력하세요!')
                broadcast(@prefix '"§f'.import('autoquiz.question_message').'§7"')
                broadcast('')
            } else if (@chance == 1) {
                switch(rand(1,20)) {
                    case 1..2:
                        @math1 = rand(2,99)
                        @math2 = rand(0,99)
                        @reward = rand(3,8)
                        export('autoquiz.question_message', @math1.' + '.@math2.' = §6???')
                        export('autoquiz.question_math_message', @math1.' + '.@math2)
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', @math1 + @math2)
                        export('autoquiz.reward', @reward)
                    case 3..4:
                        @math1 = rand(20,99)
                        @math2 = rand(0,80)
                        @reward = rand(3,8)
                        if (@math1 < @math2) {
                            @temp = @math1
                            @math1 = @math2
                            @math2 = @temp
                        }
                        export('autoquiz.question_message', @math1.' - '.@math2.' = §6???')
                        export('autoquiz.question_math_message', @math1.' - '.@math2)
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', @math1 - @math2)
                        export('autoquiz.reward', @reward)
                    case 5..6:
                        @math1 = rand(1,12)
                        @math2 = rand(1,13)
                        @reward = rand(4,10)
                        export('autoquiz.question_message', @math1.' X '.@math2.' = §6???')
                        export('autoquiz.question_math_message', @math1.' X '.@math2)
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', @math1 * @math2)
                        export('autoquiz.reward', @reward)
                    case 7..8:
                        @math1 = rand(8,99)
                        @math2 = rand(1,9)
                        @reward = rand(5,10)
                        export('autoquiz.question_message', @math1.' ÷ '.@math2.' = §6???§7(자연수)')
                        export('autoquiz.question_math_message', @math1.' ÷ '.@math2)
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', integer(@math1 / @math2))
                        export('autoquiz.reward', @reward)
                    case 9..10:
                        @math1 = rand(9,26)
                        @math2 = rand(1,4)
                        @reward = rand(6,12)
                        export('autoquiz.question_message', @math1.' 의 '.@math2.' 제곱 = §6???')
                        export('autoquiz.question_math_message', @math1.' 의 '.@math2.' 제곱')
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', integer(pow(@math1,@math2))) // or **
                        export('autoquiz.reward', @reward)
                    case 11..12:
                        @math1 = rand(0,150)
                        @math2 = rand(0,200)
                        @math3 = rand(0,175)
                        @reward = rand(4,11)
                        export('autoquiz.question_message', @math1.' + '.@math2.' - '.@math3.' = §6???')
                        export('autoquiz.question_math_message', @math1.' + '.@math2.' - '.@math3)
                        export('autoquiz.question_type', 'math')
                        export('autoquiz.question_answer', @math1 + @math2 - @math3)
                        export('autoquiz.reward', @reward)
                    case 13..14:
                        @math1 = rand(2,99)
                        @math2 = rand(0,50)
                        @result = @math1 + @math2
                        @reward = rand(4,9)
                        export('autoquiz.question_message', @math1.' + §6??? §f= '.@result)
                        export('autoquiz.question_math_message', @math1.' + '.@math2.' = '.@result)
                        export('autoquiz.question_type', 'math2')
                        export('autoquiz.question_answer', @math2)
                        export('autoquiz.reward', @reward)
                    case 15..16:
                        @math1 = rand(2,99)
                        @math2 = rand(0,50)
                        @result = @math1 + @math2
                        @reward = rand(4,9)
                        export('autoquiz.question_message', '§6??? §f+ '.@math2.' = '.@result)
                        export('autoquiz.question_math_message', @math1.' + '.@math2.' = '.@result)
                        export('autoquiz.question_type', 'math2')
                        export('autoquiz.question_answer', @math1)
                        export('autoquiz.reward', @reward)
                    case 17..18:
                        @math1 = rand(3,13)
                        @math2 = rand(1,@math1)
                        @result = @math1 * @math2
                        @reward = rand(4,9)
                        export('autoquiz.question_message', '§6??? §f* '.@math2.' = '.@result)
                        export('autoquiz.question_math_message', @math1.' * '.@math2.' = '.@result)
                        export('autoquiz.question_type', 'math2')
                        export('autoquiz.question_answer', @math1)
                        export('autoquiz.reward', @reward)
                    case 19..20:
                        @math1 = rand(3,13)
                        @math2 = rand(0,@math1)
                        @result = @math1 * @math2
                        @reward = rand(4,9)
                        export('autoquiz.question_message', @math1.' * §6??? §f= '.@result)
                        export('autoquiz.question_math_message', @math1.' * '.@math2.' = '.@result)
                        export('autoquiz.question_type', 'math2')
                        export('autoquiz.question_answer', @math2)
                        export('autoquiz.reward', @reward)
                }
                broadcast('')
                broadcast(@prefix.'§f '.import('autoquiz.question_message'))
                broadcast('')
            }

            foreach(@player in all_players()) {
                play_named_sound(ploc(@player), array('sound': 'block.note_block.pling', 'pitch': 1.2), array(@player))
            }
			console('[AutoQuiz][Info] Answer : '.import('autoquiz.question_answer'))
        }
    }
})
