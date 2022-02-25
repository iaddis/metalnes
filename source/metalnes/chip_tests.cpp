
#include "Core/Path.h"
#include "Core/StopWatch.h"
#include "Core/String.h"
#include "Core/File.h"
#include "metalnes/system.h"
#include "metalnes/nesrom.h"

#include "UnitTests.h"
#include "metalnes/wire_module.h"
#include "metalnes/handler_log.h"


extern std::string getSystemDefDir();

namespace metalnes {


//struct wire_node
//{
//    wire_module *   wires = nullptr;
//    nodeID          node_id = EMPTYNODE;
//
//    bool isNodeHigh() const {return wires->isNodeHigh(node_id);}
//    void setLow() {wires->setLow(node_id);}
//    void setHigh() {wires->setHigh(node_id);}
//    void setFloat() {wires->setFloat(node_id);}
//
//
//    operator bool() const { return isNodeHigh();}
//
//    wire_node &operator=(bool value)
//    {
//        if (value) setHigh(); else setLow();
//        return *this;
//    }
//};




//#define wire_node_field(_VAR, _NAME)            wire_node _VAR =  { _wires, resolveNode(_NAME) }
//wire_node_field(_d, "d");
//wire_node_field(__d, "/d");
//wire_node_field(_clk, "clk");
//


wire_module_ptr LoadCircuit(const char *defs_name)
{
    wire_defs_ptr defs = wire_defs::Load( getSystemDefDir(), defs_name);
    assert(defs);
    if (!defs)
        return nullptr;
    
    
    wire_module_ptr wires = WiresCreate();
    wires->addInstance(nullptr, defs, "");
    wires->resetState();
    return wires;
}

class CircuitUnitTest : public wire_handler
{
    handler_log *_log;
public:

    CircuitUnitTest(const char *name)
    : wire_handler( LoadCircuit(name), "")
    {
        _log = add_handler<handler_log>("");
    }
    
    
    void setTrace(std::string nodes_expr)
    {
        _log->setTrace(nodes_expr );
    }
    
    
    void step()
    {
        _wires->step(1);
    }

    
    void trace()
    {
        _log->captureLog();
    }
};

class UnitTest_pslatch : public CircuitUnitTest
{
public:
    UnitTest_pslatch() : CircuitUnitTest("pslatch") {}
};


TEST_CASE_METHOD( UnitTest_pslatch, "pslatch" )
{
//    _wires->setTraceLevel(1);
//    setTrace("clk,d,q,strobe,/strobe,p,ps");
    
    setLow("clk");
    setLow("d");
    setLow("p");
    setLow("ps");
    trace();
    REQUIRE(!isNodeHigh("d"));
    REQUIRE(!isNodeHigh("q"));
    setHigh("d");
    trace();
    REQUIRE(isNodeHigh("d"));
    REQUIRE(!isNodeHigh("q"));
    setLow("d");
    trace();
    REQUIRE(!isNodeHigh("d"));
    REQUIRE(!isNodeHigh("q"));

    
    
//    setLow("q");
    step();
    step();

    REQUIRE(!isNodeHigh("d"));
    REQUIRE(!isNodeHigh("q"));
    
    setHigh("d");
    step();
    REQUIRE(isNodeHigh("q"));
    
//    setHigh("clk");
    step();
    
//    setLow("clk");
//    step();
    
    setLow("d");
    step();
    
    REQUIRE(!isNodeHigh("q"));
    
//    setHigh("clk");
    step();
    step();
    step();
    

    setHigh("p");
    trace();

    setHigh("ps");
    trace();
    
    REQUIRE(isNodeHigh("q"));
    REQUIRE(!isNodeHigh("d"));

    setLow("ps");
    setLow("p");
    trace();

    REQUIRE(isNodeHigh("q"));
    REQUIRE(!isNodeHigh("d"));

    
    setHigh("ps");
    trace();

    REQUIRE(!isNodeHigh("q"));
    REQUIRE(!isNodeHigh("d"));


//    setLow("clk");
//    step();

    
//    setHigh("d");
//    REQUIRE(!isNodeHigh("/d"));
//    trace();

}







class UnitTest_4021 : public CircuitUnitTest
{
public:
    UnitTest_4021() : CircuitUnitTest("4021") {}
    
    wire_register_field(_d, "d[7:0]");

    wire_register_field(_lclk, "L[7:0].clk");
    wire_register_field(_lclkout, "L[7:0].clk_out");
    
};


TEST_CASE_METHOD( UnitTest_4021, "4021" )
{
//    setTrace("clk,d[7:0],L[7:0].clk,L[7:0].clk_out,L[7:0].d,L[7:0].q,q7,q6,q5");

    writeBits(_d, 0);
    setLow("clk");
    setLow("PL");
    trace();
    step();
    step();
    
    REQUIRE(!isNodeHigh("q7"));
    
    
    std::vector<int> tests = {0xFF, 0xCC, 0x00, 0x12};
    for (auto data : tests)
    {
        
        
        writeBits(_d, data);
        setHigh("PL");
        trace();
        setLow("PL");
        trace();

        
        
    //        _wires->setTraceLevel(1);

        for (int i=0; i < 8; i++)
        {
            REQUIRE(isNodeHigh("q7") == (((data << i) & 0x80) ? true : false) );
            REQUIRE(isNodeHigh("q6") == (((data << i) & 0x40) ? true : false) );
            REQUIRE(isNodeHigh("q5") == (((data << i) & 0x20) ? true : false) );
            
            step();
            step();
        }
        
        step();
        step();

    }


    setLow("PL");
}



} // namespace



