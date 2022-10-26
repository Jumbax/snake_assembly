.define right #08
.define left #04
.define up #01
.define down #02
.define player_pos $0200
.define command_address $4000
.define food_pos $0200
.define last_command $00
.define body_part_number $01
.define x_value $02
.define y_value $03
.define offset_movement $04
.define momentary_value $05
.define seed $06
.define counter $07
.define body_part_direction $0010
.define body_memory $0100
.ORG $8000

start:
    LDA #0
    STA body_part_number
    LDX #$FF
    LDY #0
    TXS
    LDX #0
    LDA #15
    STA seed
    JSR generate_random_num
    LDA right
    STA last_command
    JSR add_offset_movement
    JSR draw_food


loop:
    JSR draw_player
    JSR check_collision
    JSR clear
    JSR move
    JMP loop


draw_player:
    LDA #1
    STA player_pos, X
    TXA
    STA body_memory
    LDY #0
    add_one:
        CPY body_part_number
        BNE calculate_offset_movement
        RTS
        calculate_offset_movement:
            CPY #0
            BNE equal_zero
                LDA offset_movement
                STA body_part_direction, Y
                STY y_value
                JSR add_offset_movement
                TXA
                SEC
                SBC offset_movement
                SEC
                SBC y_value
                TAY
                STY momentary_value
                LDA #1
                STA player_pos, Y
                LDY y_value
                INY
                LDA momentary_value
                STA body_memory, Y
                JMP add_one
            equal_zero:
                STY y_value
                DEY
                LDA body_part_direction, Y
                INY
                STA body_part_direction, Y
                TXA
                DEY
                SEC
                SBC body_part_direction, Y
                SEC
                SBC offset_movement
                LDY #1
                check:
                CPY y_value
                BNE not_equal
                JMP then
                not_equal:
                    STY momentary_value
                    LDY y_value
                    DEY
                    SEC
                    SBC body_part_direction, Y
                    INY
                    LDY momentary_value
                    INY
                    JMP check
                then:
                    TAY
                    LDA #1
                    STA player_pos, Y
                    STY momentary_value
                    LDA #1
                    STA player_pos, Y
                    LDY y_value
                    INY
                    LDA momentary_value
                    STA body_memory, Y

                    JMP add_one
                    

add_offset_movement:
    LDA last_command
    CMP right
    BEQ assign_right
    CMP left
    BEQ assign_left
    CMP up
    BEQ assign_up
    CMP down
    BEQ assign_down
    assign_right:
        LDA #1
        STA offset_movement
        RTS
    assign_left:
        LDA #-1
        STA offset_movement
        RTS
    assign_up:
        LDA #-16
        STA offset_movement
        RTS
    assign_down:
        LDA #16
        STA offset_movement
        RTS
    

draw_food:
    LDA #10
    LDY y_value
    LDY seed
    STA food_pos, Y
    LDY y_value
    RTS


move:
    LDA command_address
    BNE check_direction
    LDA last_command
    JMP exe_move
    check_direction:
        CMP left 
        BEQ block_left
        CMP right
        BEQ block_right
        CMP up
        BEQ block_up
        CMP down
        BEQ block_down
        JMP exe_move
        block_left:
            LDA last_command
            CMP right
            BEQ block
            LDA left
            STA last_command
            JMP exe_move
            block:
                LDA right
                STA last_command
                JMP exe_move
        block_right:
            LDA last_command
            CMP left
            BEQ block2
            LDA right
            STA last_command
            JMP exe_move
            block2:
                LDA left
                STA last_command
                JMP exe_move
        block_up:
            LDA last_command
            CMP down
            BEQ block3
            LDA up
            STA last_command
            JMP exe_move
            block3:
                LDA down
                STA last_command
                JMP exe_move
        block_down:
            LDA last_command
            CMP up
            BEQ block4
            LDA down
            STA last_command
            JMP exe_move
            block4:
                LDA up
                STA last_command
                JMP exe_move
            
    exe_move:
        CMP right
        BEQ move_right
        CMP left
        BEQ move_left
        CMP up
        BEQ move_up
        CMP down
        BEQ move_down
        RTS
        move_right:
            INX
            RTS
        move_left:
            DEX
            RTS
        move_up:
            TXA 
            SEC
            SBC #16
            TAX
            RTS
        move_down:
            TXA
            CLC
            ADC #16
            TAX
            RTS


clear:
    LDA #0
    STA player_pos, X
    LDY #0
    clear_one:
        CPY body_part_number
        BNE calculate_offset_clear
        RTS
        calculate_offset_clear:
            CPY #0
            BNE equal_zero2
                STY y_value
                TXA
                SEC
                SBC offset_movement
                SEC
                SBC y_value
                TAY
                LDA #0
                STA player_pos, Y
                LDY y_value
                INY
                JMP clear_one
            equal_zero2:
                STY y_value
                DEY
                LDA body_part_direction, Y
                INY
                TXA
                DEY
                SEC
                SBC body_part_direction, Y
                SEC
                SBC offset_movement
                LDY #1
                check2:
                CPY y_value
                BNE not_equal2
                JMP then2
                not_equal2:
                    STY momentary_value
                    LDY y_value
                    DEY
                    SEC
                    SBC body_part_direction, Y
                    INY
                    LDY momentary_value
                    INY
                    JMP check2
                then2:
                    TAY
                    LDA #0
                    STA player_pos, Y
                    LDY y_value
                    INY
                    JMP clear_one
    RTS
    

check_collision:
    LDA #0
    CMP body_part_number
    BEQ food_collision
    LDA #1
    cycle:
    CMP body_part_number
    BNE check_for_collision
    JMP food_collision
    check_for_collision:
        STA counter
        LDA body_memory, Y 
        CMP body_memory
        BEQ game_over
        LDA counter
        CLC
        ADC #1
        JMP cycle
        game_over:
            NOP
        
    food_collision:
        TXA
        CMP seed
        BEQ do_food_collision
        RTS
        do_food_collision:
            JSR add_body_part
            RTS


add_body_part:
    LDA body_part_number
    CLC
    ADC #1
    STA body_part_number
    JSR generate_random_num
    JSR draw_food
    RTS


generate_random_num:
    LDA #0
    STA counter
    cycle2:
        CMP body_part_number
        BNE search_empty_space
        JMP exit
        search_empty_space:
            LDA seed
            ASL A
            ASL A
            ADC seed
            CLC
            ADC #03
            STA seed
            STY y_value
            LDY counter
            LDA body_memory, Y 
            CMP seed
            BEQ search_empty_space
            LDY y_value
            CLC
            LDA counter
            ADC #1
            STA counter
            JMP cycle2
        exit:
        RTS
    

get_vsync:
RTI


.goto $FFFA
.dw get_vsync
.dw start 
.dw start