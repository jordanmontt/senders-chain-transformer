Class {
	#name : 'BaselineOfSendersChainTransformer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSendersChainTransformer',
	#package : 'BaselineOfSendersChainTransformer'
}

{ #category : 'baselines' }
BaselineOfSendersChainTransformer >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Packages"
		spec package: 'SendersChainTransformer'.
		spec package: 'SendersChainTransformer-Tests' with: [ spec requires: #( 'SendersChainTransformer' ) ].

		"External dependencies"
		spec baseline: 'MethodProxies' with: [ spec repository: 'github://pharo-contributions/MethodProxies' ].
		spec baseline: 'IllimaniProfiler' with: [ spec repository: 'github://jordanmontt/illimani-memory-profiler:dev' ].
		spec baseline: 'PretenuringAdviceAlgorithm' with: [ spec repository: 'github://jordanmontt/Pretenuring-Advice-Algorithm:main' ].
		"Linking external dependencies"
		spec package: 'SendersChainTransformer' with: [ spec requires: #( 'MethodProxies' 'IllimaniProfiler' 'PretenuringAdviceAlgorithm') ].

		"Groups"
		spec group: 'default' with: #( 'core' 'tests' ).
		spec group: 'core' with: #( 'SendersChainTransformer' ).
		spec group: 'tests' with: #( 'SendersChainTransformer-Tests' ) ]
]
