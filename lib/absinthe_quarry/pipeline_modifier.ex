defmodule AbsintheQuarry.PipelineModifier do
  def pipeline(pipeline) do
    Absinthe.Pipeline.insert_after(
      pipeline,
      Absinthe.Phase.Schema.Validation.UniqueFieldNames,
      AbsintheQuarry.Phase.AssociationExists
    )
  end
end
