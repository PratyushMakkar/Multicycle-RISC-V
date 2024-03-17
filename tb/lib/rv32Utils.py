from lib.rv32VerifComponents import RV32Data

def randomizeData(obj: RV32Data):
  obj.preRandomize()
  obj.randomize()
  counter = 0
  while ((not obj.contraintCallback()) and counter < 5):
    obj.randomize()
    counter += 1
  obj.postRandomize()