"
An AllocationSitesExperimentTest is a test class for testing the behavior of AllocationSitesExperiment
"
Class {
	#name : 'MethodWithOffsetSerializerTest',
	#superclass : 'TestCase',
	#instVars : [
		'senders',
		'fileName'
	],
	#category : 'SendersChainTransformer-Tests-Experiment',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Experiment'
}

{ #category : 'running' }
MethodWithOffsetSerializerTest >> setUp [

    super setUp.

	 fileName := (Random new nextInteger: 100000) asString , '.json'.
    senders := {
			{
				(IllMethodWithOffset method: OrderedCollection >> #add: offset: 35).
				(IllMethodWithOffset method: OrderedCollection >> #addLast: offset: 47).
				(IllMethodWithOffset method: OrderedCollection >> #makeRoomAtLast offset: 83).
				(IllMethodWithOffset method: OrderedCollection >> #growAtLast offset: 74) }.
			{
				(IllMethodWithOffset method: Association class >> #key:value: offset: 42) } }
]

{ #category : 'running' }
MethodWithOffsetSerializerTest >> tearDown [

    fileName asFileReference delete.

    super tearDown
]

{ #category : 'tests' }
MethodWithOffsetSerializerTest >> testSerializeAndDeserialize [

    | deserializedArray writeStream |
    "Serialize"
    writeStream := fileName asFileReference createFile writeStream.
    MethodWithOffsetSerializer new serialize: senders on: writeStream.

    "Deserialize"
    deserializedArray := MethodWithOffsetSerializer new deserialize: fileName asFileReference contents.
    deserializedArray doWithIndex: [ :array :i |
            array doWithIndex: [ :methodWithOffset :j |
                    self assert: methodWithOffset method ast equals: ((senders at: i) at: j) method ast.
                    self assert: methodWithOffset offset equals: ((senders at: i) at: j) offset ] ]
]
