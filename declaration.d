import std.array, std.algorithm, std.conv;
import lexer, expression, scope_, util;

class Declaration: Expression{
	Identifier name;
	Scope scope_;
	this(Identifier name){ this.name=name; }
	override @property string kind(){ return "declaration"; }
	override string toString(){ return name?name.toString():""; }
}

class NodeDecl: Declaration{
	this(Identifier name){ super(name); }
	override @property string kind(){ return "node"; }
}
class InterfaceDecl: Declaration{
	Identifier node;
	int port;
	this(Identifier node,int port){
		super(null);
		this.node=node;
		this.port=port;
	}
	override @property string kind(){ return "interface"; }
	override string toString(){ return "("~node.toString()~", pt"~to!string(port)~")"; }
}
class LinkDecl: Declaration{
	InterfaceDecl a,b;
	this(Identifier name,InterfaceDecl a,InterfaceDecl b){ super(name); this.a=a; this.b=b; }
	override @property string kind(){ return "link"; }
	override string toString(){ return (name?name.toString~": ":"link: ")~a.toString()~" <-> "~b.toString(); }
}

class TopologyDecl: Declaration{
	NodeDecl[] nodes;
	LinkDecl[] links;
	this(NodeDecl[] nodes,LinkDecl[] links){ super(null); this.nodes = nodes; this.links=links; }
	override string toString(){ return "topology { nodes { "~nodes.map!(to!string).join(", ")~" } links{ "~links.map!(to!string).join(", ")~" } } "; }
}

class ParameterDecl: Declaration{
	Expression init_;
	this(Identifier name, Expression init_){ super(name); this.init_=init_; }
	override @property string kind(){ return "parameter"; }
	override string toString(){ assert(!!name); return name.toString()~(init_?"("~init_.toString()~")":""); }
}

class ParametersDecl: Declaration{
	ParameterDecl[] params;
	this(ParameterDecl[] params){ super(null); this.params = params; }
	override @property string kind(){ return "parameters"; }
	override string toString(){ return "parameters { "~params.map!(to!string).join(", ")~" }"; }
}

class PacketFieldsDecl: Declaration{
	Identifier[] fields;
	this(Identifier[] fields){ super(null); this.fields=fields; }
	override @property string kind(){ return "packet fields"; }
	override string toString(){ return "packet_fields { "~fields.map!(to!string).join(", ")~" }"; }
}

class ProgramsDecl: Declaration{
	ProgramMappingDecl[] mappings;
	this(ProgramMappingDecl[] mappings){ super(null); this.mappings = mappings; }
	override @property string kind(){ return "programs"; }
	override string toString(){ return "programs { "~mappings.map!(to!string).join(", ")~" }"; }
}

class ProgramMappingDecl: Declaration{
	Identifier node;
	Identifier prg;
	this(Identifier node,Identifier prg){ super(null); this.node=node; this.prg=prg; }
	override @property string kind(){ return "program mapping"; }
	override string toString(){ return node.toString()~" -> "~prg.toString(); }
}

class QueryDecl: Declaration{
	Expression query;
	this(Expression query){ super(null); this.query=query; }
	override @property string kind(){ return "query declaration"; }
	override string toString(){ return "query "~query.toString(); }
}

class CompoundDecl: Expression{
	Expression[] s;
	this(Expression[] ss){s=ss;}

	override string toString(){return "{\n"~indent(join(map!(a=>a.toString()~(a.isCompound()?"":";"))(s),"\n"))~"\n}";}
	override bool isCompound(){ return true; }

	// semantic information
	AggregateScope ascope_;
}

class StateVarDecl: Declaration{
	Expression init_;
	this(Identifier name,Expression init_){ super(name); this.init_=init_; }
	override @property string kind(){ return "state variable"; }
	override string toString(){ return name.toString()~"("~init_.toString()~")"; }
}

class StateDecl: Declaration{
	StateVarDecl[] vars;
	this(StateVarDecl[] vars){ super(null); this.vars=vars; }
	override @property string kind(){ return "state declaration"; }
	override string toString(){ return "state "~vars.map!(to!string).join(", "); }
}

class FunctionDef: Declaration{
	Identifier[] params;
	Expression rret;
	CompoundExp body_;
	this(Identifier name, Identifier[] params, Expression rret, CompoundExp body_){
		super(name); this.params=params; this.rret=rret; this.body_=body_;
	}
	override string toString(){ return "def "~(name?name.toString():"")~"("~join(map!(to!string)(params),", ")~")"~body_.toString(); }

	override bool isCompound(){ return true; }

	// semantic information
	FunctionScope fscope_;
}
