from antlr4 import *
from bashLexer import bashLexer
from bashParser import bashParser
import sys
from bashListener import bashListener
outBuffer = ""
argumentVar = ""
scopeNumber = 0


def addParameter(parameter, value):
    global outBuffer
    global scopeNumber
    for i in range(0, scopeNumber):
        outBuffer += '\t'
    outBuffer += parameter+": "+value+";\n"


def addParameterString(parameter, value):
    addParameter(parameter, '\"'+value+'\"')


def openBlock(type):
    global outBuffer
    global scopeNumber
    scopeNumber += 1
    outBuffer += type + " {\n"


def closeBlock():
    global outBuffer
    global scopeNumber
    outBuffer += "}\n"


class KeyPrinter(bashListener):
    # Enter a parse tree produced by bashParser#group.
    def enterGroup(self, ctx):
        openBlock("group")
        addParameterString("name", ctx.STRING().getText())

    # Exit a parse tree produced by bashParser#group.
    def exitGroup(self, ctx):
        closeBlock()

    # Enter a parse tree produced by bashParser#parameter.
    def enterParameter(self, ctx):
        pass

    # Exit a parse tree produced by bashParser#parameter.
    def exitParameter(self, ctx):
        global argumentVar
        addParameter(ctx.STRING().getText(), argumentVar)
        argumentVar = ""

    # Enter a parse tree produced by bashParser#argument.
    def enterArgument(self, ctx):
        global argumentVar
        argumentVar += ctx.INT().getText()

    # Exit a parse tree produced by bashParser#argument.
    #def exitArgument(self, ctx):
        #print("Exit argument")


    # Enter a parse tree produced by bashParser#arguments.
    #def enterArguments(self, ctx):
        #print("Enter arguments")
        #pass

    # Exit a parse tree produced by bashParser#arguments.
    #def exitArguments(self, ctx):
        #print("Exit arguments")

    def exitEstyleFile(self, ctx):
        print(outBuffer)


def main(argv):
    input = FileStream(argv[1])
    lexer = bashLexer(input)
    stream = CommonTokenStream(lexer)
    parser = bashParser(stream)
    tree = parser.bashFile()
    printer = KeyPrinter()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)


if __name__ == '__main__':
    main(sys.argv)
