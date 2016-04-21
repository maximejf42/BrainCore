// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of BrainCore. The full BrainCore copyright notice,
// including terms governing use, modification, and redistribution, is
// contained in the file LICENSE at the root of the source code distribution
// tree.

import Metal
import Upsurge

public typealias Blob = ValueArray<Float>

public protocol Layer {
    /// Unique layer identifier
    var id: NSUUID { get }

    /// Optional layer name
    var name: String? { get }
}

public extension Layer {
    public var descritpion: String {
        return name ?? id.UUIDString
    }

    public var debugDescription: String {
        return name ?? id.UUIDString
    }
}

public protocol DataLayer: Layer {
    /// The number of output values generated by this layer for each batch element. This value may not change after the layer is added to a network.
    var outputSize: Int { get }

    /// The data to use for the next forward pass of the network. The size of the returned data blob must be `batchSize × outputSize` and there should be `outputSize` consecutive elements for each batch.
    func nextBatch(batchSize: Int) -> Blob
}

public protocol ForwardLayer: Layer {
    /// The number of input values used by this layer for each batch element. This value may not change after the layer is added to a network.
    var inputSize: Int { get }

    /// The number of output values generated by this layer for each batch element. This value may not change after the layer is added to a network.
    var outputSize: Int { get }

    /// Initialize forward invocations and buffers
    func initializeForward(builder builder: ForwardInvocationBuilder, batchSize: Int) throws

    /// Return a list of invocations to perform forward propagation.
    var forwardInvocations: [Invocation] { get }
}

public protocol BackwardLayer: ForwardLayer {
    /// Initialize backward invocations and buffers
    func initializeBackward(builder builder: BackwardInvocationBuilder, batchSize: Int) throws

    /// Return a list of invocations to perform backpropagation.
    var backwardInvocations: [Invocation] { get }
}

public protocol TrainableLayer {
    /// Update parameters for training.
    func encodeParametersUpdate(encodeAction: (values: Buffer, deltas: Buffer) -> Void)
}

public protocol LossLayer: BackwardLayer { }

public protocol SinkLayer: Layer {
    /// The number of input values used by this layer for each batch element. This value may not change after the layer is added to a network.
    var inputSize: Int { get }

    /// Consume data generated by the network.
    func consume(input: Blob)
}
