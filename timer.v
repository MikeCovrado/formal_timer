`default_nettype none
module timer(
    input wire        clk,
    input wire        reset,
    input wire        load,
    input wire [15:0] cycles,
    output wire       busy
    );

    reg [15:0] counter;

    always @(posedge clk) begin
        if(reset)
            counter <= 0;
        else if (load)
            counter <= cycles;
        else if (counter > 0)
            counter <= counter - 1'b1;
    end

    assign busy = reset ? 1'b0 : counter > 0;

    `ifdef FORMAL
    // register for knowing if we have just started
    reg       f_past_valid = 1'b0;
    reg [1:0] f_past_cnt   = 2'b00;

    // start in reset (not required as formal engine asserts clk at t=0)
    //initial assume(reset);

    always @(posedge clk) begin

        ///////////////////////////////////////////////////////////////////////
        // SCAFFOLDING

        // update past_valid reg so we know it's safe to use $past()
        if (f_past_cnt != 2'b11) f_past_cnt   <= f_past_cnt + 2'b01;
        if (f_past_cnt == 2'b11) f_past_valid <= 1;

        ///////////////////////////////////////////////////////////////////////
        // ASSUMPTIONS (the fewer, the better)

        // start in reset for one cycle
        if (f_past_valid) assume(!reset); else assume(reset);

        // don't assert load while in reset
        //if (reset) assume(!load);

        // don't assert load while busy
        //if (busy) assume(!load);

        // don't load timer with a 0 (just 'cuz)
        //assume(cycles > 2);
        //assume(cycles < 8);

        ///////////////////////////////////////////////////////////////////////
        // COVERAGE

        // cover the counter getting loaded
        _start_: cover (load && counter > 0);

        // cover timer finishing
        if (f_past_valid)
            _finish_: cover ($past(counter > 0) && $past(busy) && (!busy));

        // busy
        _busy: cover(busy);

        ///////////////////////////////////////////////////////////////////////
        // ASSERTIONS

        // load works
        // This can be simplified if (reset) assume(!load); is a valid assumption
        if (f_past_valid)
            if ($past(load) && !$past(reset))
                _loadworks_: assert(counter == $past(cycles));

        // counts down
        // This can be simplified if (busy) assume(!load); is a valid assumption
        if (f_past_valid)
            if ($past(busy) && !$past(load))
                _countdown_: assert(counter == $past(counter) - 1);
    end
    `endif

endmodule
