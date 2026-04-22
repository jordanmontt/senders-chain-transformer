"
An AllocationSitesExperimentTest is a test class for testing the behavior of AllocationSitesExperiment
"
Class {
	#name : 'CompiledMethodToSourceCodeSerializerTest',
	#superclass : 'TestCase',
	#instVars : [
		'fileName',
		'compiledMethods'
	],
	#category : 'SendersChainTransformer-Tests-Experiment',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Experiment'
}

{ #category : 'running' }
CompiledMethodToSourceCodeSerializerTest >> setUp [

	super setUp.

	fileName := (Random new nextInteger: 100000) asString , '.json'.
	compiledMethods := {
		                   (SCMockClassWithDumbMethods >> #addOccupant:).
		                   (SCMockClassWithDumbMethods >> #@).
		                   (SCMockClassWithDumbMethods >> #availableProbes).
		                   (SCMockClassWithDumbMethods >> #bar) }
]

{ #category : 'running' }
CompiledMethodToSourceCodeSerializerTest >> tearDown [

    fileName asFileReference delete.

    super tearDown
]

{ #category : 'tests' }
CompiledMethodToSourceCodeSerializerTest >> testSerializeAndDeserialize [

    | deserializedCompiledMethods writeStream |
    "Serialize"
    writeStream := fileName asFileReference createFile writeStream.
    CompiledMethodToSourceCodeSerializer new serialize: compiledMethods on: writeStream.

    "Deserialize"
    deserializedCompiledMethods := CompiledMethodToSourceCodeSerializer new
        deserialize: fileName asFileReference contents.
    deserializedCompiledMethods doWithIndex: [ :aCompiledMethod :i |
        self assert: aCompiledMethod parseTree equals: (compiledMethods at: i) parseTree.
        self assert: aCompiledMethod selector equals: (compiledMethods at: i) selector.
        self assert: aCompiledMethod methodClass equals: (compiledMethods at: i) methodClass ]
]
