import os
MY_TEST = os.environ['MY_TEST']

match MY_TEST:
  case "INSTRUCTION_FETCH_STAGE":
    from tests.rv32_instruction_fetch_test import rv32_instruction_repeated_test
  case "ALU_EXECUTE_FSM":
    from tests.rv32_alu_fsm_test import rv32_alu_fsm_test
  case "REGISTER_FILE_TEST":
    from tests.rv32_register_file_test import directed_sanity_test, write_only_sanity_test
  case _:
    from tests.rv32_wrapper_test import wrapper_test

