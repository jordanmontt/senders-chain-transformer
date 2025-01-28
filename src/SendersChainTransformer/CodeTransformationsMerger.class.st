Class {
	#name : 'CodeTransformationsMerger',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'api' }
CodeTransformationsMerger >> hasDuplicateMethodTransformations: anArrayOfCompiledMethods [

	^ (anArrayOfCompiledMethods collect: #name as: Set) size ~= anArrayOfCompiledMethods size
]

{ #category : 'internals' }
CodeTransformationsMerger >> mergeCompiledMethods: compiledMethodsWithTransformations into: originalCompiledMethod [

	| astToTransform mergedCompiledMethod |
	astToTransform := originalCompiledMethod parseTree.
	compiledMethodsWithTransformations do: [ :aCompiledMethod |
		(astToTransform allChildren select: #isMessage)
			with: (aCompiledMethod parseTree allChildren select: #isMessage)
			do: [ :nodeToTransform :nodeWithChanges |
				(nodeWithChanges selector includesSubstring: 'tenured' caseSensitive: false) ifTrue: [
					nodeToTransform selector: nodeWithChanges selector ] ] ].
	mergedCompiledMethod := astToTransform methodNode generateIR generate.
	mergedCompiledMethod propertyAt: #source put: astToTransform formattedCode.
	^ mergedCompiledMethod
]

{ #category : 'api' }
CodeTransformationsMerger >> mergeTransformedCompiledMethods: compiledMethods [

	| repetitions |	
	(self hasDuplicateMethodTransformations: compiledMethods) ifFalse: [ ^ compiledMethods ].
	
	repetitions := Dictionary new.
	compiledMethods do: [ :aCompiledMethod |
		repetitions
			at: aCompiledMethod name
			ifPresent: [ :col | col add: aCompiledMethod ]
			ifAbsentPut: [ OrderedCollection with: aCompiledMethod ] ].

	(repetitions select: [ :col | col size > 1 ]) keysAndValuesDo: [ :methodName :collection |
		| originalCompiledMethod mergedCompiledMethod |
		originalCompiledMethod := (OpalCompiler new source: methodName; evaluate).
		mergedCompiledMethod := self mergeCompiledMethods: collection into: originalCompiledMethod.
		repetitions at: methodName put: { mergedCompiledMethod } "Put the merged method" ].

	^ repetitions values flattened
]
