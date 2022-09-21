import pandas as pd

class DataTransformer:
	def __init__(self):
		self.df = ""

	def import_xml(self, filename):
		self.df = pd.read_xml(filename)

	def export_csv(self, filename):
		self.df.to_csv(filename, index=False)

def main():
	dtf = DataTransformer()

	# Import an XML file
	dtf.import_xml("test.xml")

	# Export Dataframe as CSV
	dtf.export_csv("test.csv")

if __name__ == '__main__':
	main()