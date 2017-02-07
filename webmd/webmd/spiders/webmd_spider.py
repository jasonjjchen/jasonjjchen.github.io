from scrapy import Spider, Request
from scrapy.selector import Selector
from webmd.items import WebmdItem
import time
import re


class WebmdSpider(Spider):
    name = "webmd_spider"
    allowed_urls = ['http://www.webmd.com/']
    start_urls = ['http://www.webmd.com/drugs/index-drugs.aspx?show=conditions']


    # def parse(self, response):
    #     # follow links to next alphabet page
    #     atoz = response.xpath('//*[@id="drugs_view"]/li/a/@href').extract()
    #     print "parsing..."
    #     for i in range(2, len(atoz)):
    #
    #         yield Request(response.urljoin(atoz[i]), \
    #                              callback = self.parse_az)


    # def parse_az(self, response):
    #     # follow links to condition
    #     Aa = response.xpath('//*[@id="showAsubNav"]/ul/li').extract()
    #     print "selecting alphabet..."
    #     for i in range(len(Aa)):
    #
    #         yield Request(response.urljoin(Selector(text = Aa[i]).xpath('//a/@href').extract()[0]), \
    #                       callback = self.parse_condition)


    def parse(self, response):
        # follow links to drugs
        table = response.xpath('//*[@id="az-box"]/div//a').extract()
        print "scraping condition and following link to drugs..."
        for i in range(len(table)):
            Condition = response.xpath('//*[@id="az-box"]/div//a/text()').extract()[i]

            yield Request(response.urljoin(response.xpath('//*[@id="az-box"]/div//a/@href').extract()[i]), \
                          callback = self.parse_drug, meta = {'Condition' : Condition})


    def parse_drug(self, response):
        # following links to drug details
        rows = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr').extract()
        print "scraping drug info and following link to details..."

        for i in range(len(rows)):
            Drug = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[1]/a/text()').extract()[i]
            Indication = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[2]/@class').extract()[i].replace('drug_ind_fmt', '')
            Type = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[3]/@class').extract()[i].replace('drug_type_fmt', '')
            Review = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[4]/a/text()').extract()[i].replace('\r\n', '')
            Condition = response.meta['Condition']

            aspx_index = response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[1]/a/@href').extract()[i].find('aspx') + 4

            yield Request(response.urljoin(response.xpath('//*[@id="vit_drugsContent"]/div/div/table[2]/tr/td[1]/a/@href').extract()[i][:aspx_index]),\
                          callback = self.parse_details, meta = {'Condition': Condition, 'Drug': Drug, 'Indication': Indication, 'Type': Type, 'Review': Review})


    def parse_details(self, response):
        Condition = response.meta['Condition']
        Drug = response.meta['Drug']
        Indication = response.meta['Indication']
        Type = response.meta['Type']
        Review = response.meta['Review']

        print "scraping details and following link to contraindications..."

        if re.search('Your search for', response.body):
            yield Request(response.urljoin(response.xpath('//*[@id="ContentPane28"]/div/section/p[1]/a//@href').extract()[0]), \
                          callback = self.parse_details, meta = {'Condition': Condition, 'Drug': Drug, 'Indication': Indication, 'Type': Type, 'Review': Review})

        else:
            Use = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/div/div/div[3]/div[1]/div[1]/p[1]//text()').extract())
            # HowtoUse = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/div/div/div[3]/div[1]/div[1]/h3/following-sibling::p//text()').extract())
            Sides = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/div/div/div[3]/div[2]/div/p[1]//text()').extract()).replace('\r\n', '')
            # Precautions = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/div/div/div[3]/div[3]/div/p/text()').extract())
            Interactions = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/div/div/div[3]/div[4]/div[1]/p[2]//text()').extract())
            # Condition = response.meta['Condition']
            # Drug = response.meta['Drug']
            # Indication = response.meta['Indication']
            # Type = response.meta['Type']
            # Review = response.meta['Review']



            yield Request(response.urljoin(response.url + '/list-contraindications'),\
                          callback = self.parse_avoid, meta = {'Condition': Condition, 'Drug': Drug, 'Indication': Indication, 'Type': Type, 'Review': Review,\
                                                               'Use': Use, \
                                                               # 'HowtoUse': HowtoUse, \
                                                               'Sides': Sides,\
                                                               #  'Precautions': Precautions,\
                                                               'Interactions': Interactions})


    def parse_avoid(self, response):

        print "scraping avoid use cases..."

        Condition = response.meta['Condition']
        Drug = response.meta['Drug']
        Indication = response.meta['Indication']
        Type = response.meta['Type']
        Review = response.meta['Review']
        Use = response.meta['Use']
        # HowtoUse = response.meta['HowtoUse']
        Sides = response.meta['Sides']
        # Precautions = response.meta['Precautions']
        Interactions = response.meta['Interactions']
        AvoidUse = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/article/section/p[2]/text()').extract())
        Allergies = ' '.join(response.xpath('//*[@id="ContentPane28"]/div/article/section/p[3]/text()').extract())

        if not AvoidUse:
            AvoidUse = ' '
        if not Allergies:
            Allergies = ' '

        item = WebmdItem()

        item['AvoidUse'] = AvoidUse
        item['Allergies'] = Allergies
        item['Use'] = Use
        # item['HowtoUse'] = HowtoUse
        # item['Precautions'] = Precautions
        item['Interactions'] = Interactions
        item['Sides'] = Sides
        item['Condition'] = Condition
        item['Drug'] = Drug
        item['Indication'] = Indication
        item['Type'] = Type
        item['Review'] = Review

        yield item