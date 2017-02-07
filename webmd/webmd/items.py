from scrapy import Item, Field

class WebmdItem(Item):
    Drug = Field()
    Indication = Field()
    Type = Field()
    Review = Field()
    Condition = Field()
    Use = Field()
    # HowtoUse = Field()
    Sides = Field()
    # Precautions = Field()
    Interactions = Field()
    AvoidUse = Field()
    Allergies = Field()

