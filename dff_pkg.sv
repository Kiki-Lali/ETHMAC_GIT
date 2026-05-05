// DFF UVM Package
package dff_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ============================================================================
  // Sequence Item / Transaction
  // ============================================================================
  class dff_seq_item extends uvm_sequence_item;
    `uvm_object_utils(dff_seq_item)

    rand logic data_in;
    logic data_out;
    logic valid;

    constraint c_valid_data { data_in inside {0, 1}; }

    function new(string name = "dff_seq_item");
      super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
      dff_seq_item rhs_;
      if (!$cast(rhs_, rhs))
        `uvm_fatal("COPY", "cast failed")
      super.do_copy(rhs);
      this.data_in  = rhs_.data_in;
      this.data_out = rhs_.data_out;
      this.valid    = rhs_.valid;
    endfunction

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      dff_seq_item rhs_;
      bit result;
      if (!$cast(rhs_, rhs))
        `uvm_fatal("COMPARE", "cast failed")
      result = super.do_compare(rhs, comparer);
      result &= comparer.compare_field("data_in", this.data_in, rhs_.data_in, $bits(this.data_in));
      result &= comparer.compare_field("data_out", this.data_out, rhs_.data_out, $bits(this.data_out));
      result &= comparer.compare_field("valid", this.valid, rhs_.valid, $bits(this.valid));
      return result;
    endfunction

    function string convert2string();
      return $sformatf("data_in=%b, data_out=%b, valid=%b", data_in, data_out, valid);
    endfunction

  endclass

  // ============================================================================
  // Driver
  // ============================================================================
  class dff_driver extends uvm_driver #(dff_seq_item);
    `uvm_component_utils(dff_driver)

    virtual dff_if.driver vif;
    dff_seq_item seq_item;

    function new(string name = "dff_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db #(virtual dff_if.driver)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
      reset_signals();
      while (1) begin
        seq_item_port.get_next_item(seq_item);
        drive_transaction(seq_item);
        seq_item_port.item_done();
      end
    endtask

    task reset_signals();
      vif.cb.reset  <= 1'b0;
      vif.cb.data_in <= 1'b0;
      @(vif.cb);
      @(vif.cb);
      vif.cb.reset <= 1'b1;
      @(vif.cb);
    endtask

    task drive_transaction(dff_seq_item txn);
      vif.cb.data_in <= txn.data_in;
      @(vif.cb);
    endtask

  endclass

  // ============================================================================
  // Monitor
  // ============================================================================
  class dff_monitor extends uvm_monitor;
    `uvm_component_utils(dff_monitor)

    virtual dff_if.monitor vif;
    uvm_analysis_port #(dff_seq_item) ap;
    dff_seq_item collected_txn;

    function new(string name = "dff_monitor", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db #(virtual dff_if.monitor)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        collect_transaction();
      end
    endtask

    task collect_transaction();
      @(posedge vif.clk);
      collected_txn = dff_seq_item::type_id::create("collected_txn");
      collected_txn.data_out = vif.data_out;
      collected_txn.valid = vif.valid;
      ap.write(collected_txn);
    endtask

  endclass

  // ============================================================================
  // Scoreboard
  // ============================================================================
  class dff_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dff_scoreboard)

    uvm_analysis_imp #(dff_seq_item, dff_scoreboard) ap;
    logic expected_data;
    int pass_count = 0;
    int fail_count = 0;

    function new(string name = "dff_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
      expected_data = 1'b0;
    endfunction

    function void write(dff_seq_item txn);
      if (txn.data_out == expected_data) begin
        `uvm_info("PASS", $sformatf("Data match: expected=%b, got=%b", expected_data, txn.data_out), UVM_LOW)
        pass_count++;
      end else begin
        `uvm_error("FAIL", $sformatf("Data mismatch: expected=%b, got=%b", expected_data, txn.data_out))
        fail_count++;
      end
      expected_data = txn.data_out;  // Update for next cycle
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("SCORE", $sformatf("Passed: %0d, Failed: %0d", pass_count, fail_count), UVM_MEDIUM)
    endfunction

  endclass

  // ============================================================================
  // Sequencer
  // ============================================================================
  typedef uvm_sequencer #(dff_seq_item) dff_sequencer;

  // ============================================================================
  // Sequences
  // ============================================================================
  class dff_base_seq extends uvm_sequence #(dff_seq_item);
    `uvm_object_utils(dff_base_seq)

    function new(string name = "dff_base_seq");
      super.new(name);
    endfunction

  endclass

  class dff_random_seq extends dff_base_seq;
    `uvm_object_utils(dff_random_seq)
    int num_of_items = 10;

    function new(string name = "dff_random_seq");
      super.new(name);
    endfunction

    task body();
      repeat (num_of_items) begin
        req = dff_seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize());
        finish_item(req);
      end
    endtask

  endclass

  class dff_all_zeros_seq extends dff_base_seq;
    `uvm_object_utils(dff_all_zeros_seq)

    function new(string name = "dff_all_zeros_seq");
      super.new(name);
    endfunction

    task body();
      repeat (5) begin
        req = dff_seq_item::type_id::create("req");
        start_item(req);
        req.data_in = 1'b0;
        finish_item(req);
      end
    endtask

  endclass

  class dff_all_ones_seq extends dff_base_seq;
    `uvm_object_utils(dff_all_ones_seq)

    function new(string name = "dff_all_ones_seq");
      super.new(name);
    endfunction

    task body();
      repeat (5) begin
        req = dff_seq_item::type_id::create("req");
        start_item(req);
        req.data_in = 1'b1;
        finish_item(req);
      end
    endtask

  endclass

  // ============================================================================
  // Environment
  // ============================================================================
  class dff_env extends uvm_env;
    `uvm_component_utils(dff_env)

    dff_sequencer sequencer;
    dff_driver driver;
    dff_monitor monitor;
    dff_scoreboard scoreboard;

    function new(string name = "dff_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = dff_sequencer::type_id::create("sequencer", this);
      driver = dff_driver::type_id::create("driver", this);
      monitor = dff_monitor::type_id::create("monitor", this);
      scoreboard = dff_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.ap.connect(scoreboard.ap);
    endfunction

  endclass

  // ============================================================================
  // Base Test
  // ============================================================================
  class dff_base_test extends uvm_test;
    `uvm_component_utils(dff_base_test)

    dff_env env;

    function new(string name = "dff_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dff_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      print(uvm_default_tree_printer);
    endfunction

  endclass

  // ============================================================================
  // Test Cases
  // ============================================================================
  class dff_random_test extends dff_base_test;
    `uvm_component_utils(dff_random_test)

    function new(string name = "dff_random_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      dff_random_seq seq;
      phase.raise_objection(this);
      seq = dff_random_seq::type_id::create("seq");
      seq.num_of_items = 20;
      seq.start(env.sequencer);
      #100ns;
      phase.drop_objection(this);
    endtask

  endclass

  class dff_zeros_ones_test extends dff_base_test;
    `uvm_component_utils(dff_zeros_ones_test)

    function new(string name = "dff_zeros_ones_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      dff_all_zeros_seq zeros_seq;
      dff_all_ones_seq ones_seq;
      phase.raise_objection(this);
      
      zeros_seq = dff_all_zeros_seq::type_id::create("zeros_seq");
      zeros_seq.start(env.sequencer);
      
      ones_seq = dff_all_ones_seq::type_id::create("ones_seq");
      ones_seq.start(env.sequencer);
      
      #100ns;
      phase.drop_objection(this);
    endtask

  endclass

endpackage
