include('proc.ms')

bind('player_chat', null, null, @Data){
    @prefix = _chprefix('d')
    if (import('autoquiz.status') == 0, exit())
    if (@Data['message'] == import('autoquiz.question_answer')) {
        cancel()
        @player = @Data['player']

        if (array_contains(_getUser(), @player)) {
            msg(@prefix'§6이미 보상을 받으셨습니다.')
            die()
        }

        @reward = import('autoquiz.reward')
        @chance = import('autoquiz.chance')
        if (@reward < 1, @reward = 1)
        if (@chance == 1, @message = "§e+".@reward."원", @message = "§a경험치 +".@reward)

        @size = array_size(_getUser())
        if (@size == 0) {
            if (@chance == 3 || @chance == 4) {
                broadcast(@prefix @player'님이 가장 빠르게 문장을 입력하셨습니다!')
                export('autoquiz.settime', time() + 5000)
            } else {
                broadcast(@prefix @player'님이 가장 빠르게 문제의 정답을 맞추셨습니다!')
                export('autoquiz.settime', time() + 4000)
            }
            broadcast(@prefix'§7보상 : '.@message)
            export('autoquiz.status', 2)
        } else {
            @size = @size + 1
            if (@chance == 3 || @chance == 4) {
                msg(@prefix'당신은 '.@size.'번째로 문장을 입력하셨습니다!')
            } else {
                msg(@prefix'당신은 '.@size.'번째로 정답을 맞추셨습니다!')
            }
            msg(@prefix'§7보상 : '.@message)
        }

        if (@chance == 1, acc_add(@player, @reward), runas('~console', '/giveexp'@player @reward))
        export('autoquiz.reward', round(@reward / 1.4, 3))
        _addUser(@player)
    }
}
