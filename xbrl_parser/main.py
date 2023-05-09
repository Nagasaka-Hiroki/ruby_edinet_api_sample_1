from arelle import ModelManager
from arelle import Cntlr

#xbrlファイルを記述する。
filename='S100Q71I/XBRL/PublicDoc/jpcrp040300-q3r-001_E02144-000_2022-12-31_01_2023-02-13.xbrl'

#cntrl=Cntlr.Cntlr(logFileName='logToPrint')
cntrl=Cntlr.Cntlr()
model_manager=ModelManager.initialize(cntrl)

model_xbrl=model_manager.load(filename)


for fact in model_xbrl.facts:
    #if fact.concept.qname.localName=="FilerNameInJapaneseDEI":
    #print(fact.value)
    print(fact.concept.qname.localName)